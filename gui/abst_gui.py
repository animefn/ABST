
from PyQt5 import QtWidgets
from PyQt5.QtGui import *
from PyQt5.QtWidgets import QTableWidgetItem,QHeaderView,QFileDialog #,QWidget

from PyQt5.QtCore import QDir,QFileInfo,Qt,QMimeDatabase,QProcess, QSize,QTranslator,QCoreApplication,QThread,pyqtSignal


from abst_conf import ABSTConfig
import abst_ui

import os
import sys
import subprocess
import traceback
import webbrowser

# Future feauture: maybe someday dnd on widget only instead of window specially if we need DND for other things
#        https://stackoverflow.com/questions/71098302/drag-and-drop-files-to-qtablewidget
#        https://stackoverflow.com/questions/10264040/how-to-drag-and-drop-into-a-qtablewidget-pyqt





def app_dir():
    """Folder that holds ABST.exe (or abst_gui.py when running from source).

    Everything the app loads at runtime -- abst_cli.exe, themes/, lang/,
    abst_settings.ini -- sits next to it. We must NOT rely on the working
    directory: it is whatever the caller happened to be in (a shortcut, a
    pinned taskbar entry, running the exe straight out of the 7z viewer,
    drag-and-dropping files onto it...), and then every relative path breaks.
    For a --onefile build sys.executable is ABST.exe itself, not _MEIPASS,
    which is what we want since these files ship unbundled beside it.
    """
    if getattr(sys, 'frozen', False):
        return os.path.dirname(os.path.abspath(sys.executable))
    return os.path.dirname(os.path.abspath(__file__))

APP_DIR = app_dir()
proc = os.path.join(APP_DIR, "abst_cli.exe")
# Kept relative on purpose for the "start ... CMD /K" command line below:
# once we chdir into APP_DIR this resolves, and it dodges the quoting rules
# that a path containing spaces would hit inside cmd /K.
PROC_REL = r".\abst_cli.exe"
# proc=r"D:\apps\fansub-tools\abst-dev\script.exe"

# Hide the console window of the CLI probes below; the GUI has no console of
# its own, so without this each check_output() flashes a black box.
CREATE_NO_WINDOW = 0x08000000 if sys.platform == "win32" else 0

GUI_VERSION=6


def run_cli(*cli_args, timeout=10):
    """Call abst_cli.exe by absolute path and return its stdout, stripped.

    The timeout matters: -check_update does a web request, and when the update
    server is unreachable it can sit there for minutes before giving up. That
    ran before the window was created, so the app looked like it never started.
    check_output kills the child when the timeout fires, so we do not leak a
    stuck abst_cli.exe per launch either.
    """
    return subprocess.check_output(
        [proc, *cli_args],
        stderr=subprocess.DEVNULL,
        creationflags=CREATE_NO_WINDOW,
        timeout=timeout,
    ).decode('utf-8', errors='replace').strip()



def change_material_style(stylename=""):
    if stylename=="":
        app.setStyleSheet ("")
        return
    app.setStyle("windowsvista")
    QDir.addSearchPath(f'icon_{stylename}', f"themes\\{stylename}\\icons")
    with open(f"themes/{stylename}/{stylename}.qss", 'r') as file:
            app.setStyleSheet ( file.read())
    # QDir.addSearchPath(f'icon_{stylename}', f"themes\{stylename}\icons") #put before loading qss and it fixes the not found issuse!



def change_style(event):
    
    if event=="modern light":
        app.setStyle("fusion")
        change_material_style()
    elif event=="classic light":
        app.setStyle("windowsvista")
        change_material_style()
    else :
        change_material_style(event)#put sylename inside

def sizeof_fmt(num, suffix="B"):
    for unit in ["", "K", "M", "G", "T", "P", "E", "Z"]:
        if abs(num) < 1024.0:
            return f"{num:3.1f}{unit}{suffix}"
        num /= 1024.0
    return f"{num:.1f}Yi{suffix}"



class UpdateCheck(QThread):
    """Ask the CLI for the latest published version, off the UI thread.

    This is a web request. Doing it inline meant the window could not appear
    until the update server answered -- which, offline or behind a firewall,
    is never. The window now opens immediately and the label fills in later.
    """
    checked = pyqtSignal(object, object)

    def run(self):
        cli_latest = gui_latest = None
        try:
            out = run_cli('-check_update', timeout=8)
            cli_latest, gui_latest = out.split("[")[1].split("]")[0].split("g")
        except Exception:
            traceback.print_exc()
        self.checked.emit(cli_latest, gui_latest)


class AbstGUi (QtWidgets.QMainWindow,abst_ui.Ui_MainWindow):
    def __init__(self, parent=None):
        
        # change_material_style("dark_teal")
        # change_material_style()
        # None of this is allowed to stop the window from opening: the version
        # banner is cosmetic, but it used to run before super().__init__() and
        # any failure killed the app before it drew a single pixel.
        try:
            self.CLI_VERSION=run_cli('-v', timeout=15)
        except Exception:
            traceback.print_exc()
            self.CLI_VERSION="?"
        self.CG_VERSION=f"{self.CLI_VERSION}g{GUI_VERSION}"

        # Filled in by the UpdateCheck thread once it answers (see below).
        self.CLI_latest,self.GUI_latest=None,None
        self.update_checked=False


        super(AbstGUi, self).__init__(parent)
        ###
        self.conf= ABSTConfig()
        self.trans = QTranslator(self)
        
        


        theme= "modern light"
        lang= "English"
        if self.conf.ui_theme : theme = self.conf.ui_theme 
        if self.conf.ui_lang : lang = self.conf.ui_lang
        
        QtWidgets.QApplication.instance().installTranslator(self.trans)
        
        change_style(theme)
        
        ###
        self.setupUi(self)
        self.change_lang(lang)
        self.setAcceptDrops(True)
        # title="ABST: Batch (hard)Subbing Tool "
        # self.setWindowTitle(title)

        screenSize = QtWidgets.QApplication.desktop().availableGeometry(self)
        w =screenSize.width() * 0.7
        self.resize(QSize(self.width(), int(screenSize.height() * 0.8)))
        
    
        self.param_files = set()
        ###
        
        ##
        
        # QtWidgets.QApplication.instance().installTranslator(self.trans)
        
        # tableWidget_files #use minimumSectionSize?
        # self.tableWidget_files.horizontalHeaderItem(0).setText("file")
        # self.tableWidget_files.horizontalHeaderItem(1).setText("size")
        self.set_versionupdate_label()
        self.tableWidget_files.setHorizontalHeaderLabels([self.tr('filename'), self.tr('size')])
        
        self.tableWidget_files.setTextElideMode(Qt.ElideLeft)   
        self.tableWidget_files.setWordWrap(False)
 
        self.tableWidget_files.setSizeAdjustPolicy(
        QtWidgets.QAbstractScrollArea.AdjustToContents)
        self.tableWidget_files.resizeColumnsToContents()

        tbl_width=self.tableWidget_files.width()
        self.tableWidget_files.setColumnWidth(1,int(tbl_width*0.25))
        
        header = self.tableWidget_files.horizontalHeader()
        header.setSectionResizeMode(0, QHeaderView.ResizeMode.Stretch)
        
        #icons
        name= QtWidgets.QStyle.SP_DirIcon
        icon=self.centralwidget.style().standardIcon(name)
        self.tbtn_outdir.setIcon(icon)
        
        name= QtWidgets.QStyle.SP_FileDialogNewFolder
        icon=self.centralwidget.style().standardIcon(name)
        self.tbtn_addfiles.setIcon(icon)

        name= QtWidgets.QStyle.SP_MessageBoxCritical
        icon=self.centralwidget.style().standardIcon(name)
        self.tbtn_rmfiles.setIcon(icon)

        # Connectors
        self.tbtn_addfiles.clicked.connect(self.add_files_via_dialog)
        self.tbtn_rmfiles.clicked.connect(self.remove_files)
        self.tbtn_outdir.clicked.connect(self.select_out_dir)
        self.tbtn_fontsdir.clicked.connect(self.select_fonts_dir)

        self.comboBox_audio.currentTextChanged.connect(self.audio_setting)
        
        self.comboBox_style.currentTextChanged.connect(change_style)
        self.comboBox_style.currentTextChanged.connect(self.conf.update_theme)
        self.comboBox_style.setCurrentText(theme)
        
        #do the same 3 lines for language later
        #con.update_lang("ar")
        self.comboBox_lang.currentTextChanged.connect(self.change_lang)
        self.comboBox_lang.currentTextChanged.connect(self.conf.update_lang)
        self.comboBox_lang.setCurrentText(lang)
        # self.checkBox_qtstyle.stateChanged.connect(change_qt_style)
        
        self.checkBox_outdir.stateChanged.connect(self.enable_disable_output) 
        
        self.pbtn_launchCLI.clicked.connect(self.launch_abstCLI)
        
        self.pbtn_update.clicked.connect(lambda: webbrowser.open('https://github.com/animefn/ABST/releases/latest'))
        self.pbtn_donate.clicked.connect(lambda: webbrowser.open('http://animefn.com'))

        # Kick off the update check now that the UI is built and about to show.
        self.update_thread=UpdateCheck(self)
        self.update_thread.checked.connect(self.on_update_checked)
        self.update_thread.start()

        #self.retranslateUi()
    def on_update_checked(self,cli_latest,gui_latest):
        self.CLI_latest,self.GUI_latest=cli_latest,gui_latest
        self.update_checked=True
        self.set_versionupdate_label()

    def closeEvent(self,event):
        # Don't let Qt tear down a still-running QThread on exit. The worker is
        # bounded by the subprocess timeout above, so this waits at most that
        # long, and only if the window is closed mid-check (normally instant).
        if self.update_thread.isRunning():
            self.update_thread.wait(10000)
        QtWidgets.QMainWindow.closeEvent(self,event)

    def set_versionupdate_label (self):
        if not self.update_checked:
            ver_status='<br><span style=" color:#808080;">'+self.tr("checking for updates...")+'</span>'
            self.label_verNb.setText(self.CG_VERSION+ver_status)
            return
        ver_status='<br><span style=" color:#5AAB61;"><b>'+self.tr("latest")+'</b></span>'
        # print(">>>>> G" ,self.GUI_latest)
        try:
            if float(self.CLI_latest)>float(self.CLI_VERSION) or int(self.GUI_latest)>int(GUI_VERSION):
                ver_status='<br><span style=" color:#ff0000;"><b>'+self.tr("Please update")+'</b></span>'
        except:
            ver_status='<br><span style=" color:#ff0000;"><b>'+self.tr("Error checking latest version")+'</b></span>'
        self.label_verNb.setText(self.CG_VERSION+ver_status)

    def swap_direction(self,rtl=True):
        dir=Qt.LeftToRight
        al = Qt.AlignLeft
        if rtl: 
            dir=Qt.RightToLeft
            al = Qt.AlignRight
        # self.label_instructions.setLayoutDirection(Qt.RightToLeft)
        self.setLayoutDirection(dir)
        # self.groupBox2.setLayoutDirection(Qt.LeftToRight)
        self.groupBox1.setLayoutDirection(dir)
        self.label_instructions.setLayoutDirection(dir)
        self.label_instructions.setAlignment(al)
        #self.groupBox.setLayoutDirection(opposite)
        self.checkBox_outdir.setLayoutDirection(dir)
        for o in [ self.comboBox_tune, self.comboBox_preset,self.comboBox_downscale,self.spinBox_crf,
                   self.comboBox_audio,self.spinBox_audio_quality,self.comboBox_subsettings,
                   self.tableWidget_files]:
            o.setLayoutDirection(Qt.LeftToRight)

    def change_lang(self,new_lang):
        lang_dict={
            "English": "",
            "العربية": "arabic",
            "Français": "french"
        }
        
        if new_lang=="العربية":
            #RTL
            self.swap_direction()
            print("arabic")
        else:
            self.swap_direction(rtl=False)
        
        self.trans.load(f"lang/{lang_dict[new_lang]}")
        
        QtWidgets.QApplication.instance().installTranslator(self.trans)
        self.tl_ui()
        #
    def tl_ui(self):
        self.retranslateUi(self)
        self.tableWidget_files.setHorizontalHeaderLabels([self.tr('filename'), self.tr('size')])
        self.set_versionupdate_label()

    def resizeEvent(self, event):
        print("resizing")
        QtWidgets.QMainWindow.resizeEvent(self, event)
        tbl_width=self.tableWidget_files.width()
        
        self.tableWidget_files.setColumnWidth(1,int(tbl_width*0.25))
        print(f"resizing {tbl_width}")
    def audio_setting(self,event):
        print(event)
        boolvalue= event=="disable" or event=="copy"
        self.spinBox_audio_quality.setEnabled( not(boolvalue)) 
        

    def enable_disable_output(self,event):
        print(event)
        enable_bool = self.checkBox_outdir.isChecked()
        print(f"gotta enable the field/disable it{enable_bool}")
        self.output_path.setEnabled(enable_bool)
        # self.lineEdit.setObjectName("lineEdit")
        # self.horizontalLayout_2.addWidget(self.lineEdit)
        # self.tbtn_outdir = QtWidgets.QToolButton(self.centralwidget)
        self.tbtn_outdir.setEnabled(enable_bool)

    def select_out_dir(self):
        folderpath = QtWidgets.QFileDialog.getExistingDirectory(self, self.tr('Select output Folder'))
        self.output_path.setText(folderpath)
    def select_fonts_dir(self):
        folderpath = QtWidgets.QFileDialog.getExistingDirectory(self, self.tr('Select fonts Folder'))
        self.fontsdir_path.setText(folderpath)
    def remove_files(self):
        s2=self.tableWidget_files.selectedIndexes()
        print(f"files before {self.param_files}")
        rows = set()
        for index in s2:
            rows.add(index.row())
        for row in sorted(rows, reverse=True):
            filename=self.tableWidget_files.item(row,0).text()
            print (f"removing {filename}")
            self.param_files.remove( filename )
            self.tableWidget_files.removeRow(row)
        print(f"files after {self.param_files}")
        
        # for e in s2:
        #     print(e.row())
        #     rm_idx+=1
        #     self.tableWidget_files.removeRow(e.row()-rm_idx)
        
    def add_files_to_table(self,filenames):
        currentRowCount=self.tableWidget_files.rowCount()
        duplicate_list=[]
        if filenames:
            for f in filenames:
                #print(filename)
                print(f)
                #refactor to an add function
                if f in self.param_files:
                    duplicate_list.append(f)
                    continue
                self.param_files.add(f)
                self.tableWidget_files.insertRow(currentRowCount)
                self.tableWidget_files.setItem(currentRowCount , 0, QTableWidgetItem(f))
                #get_filesize here
                fsize=QFileInfo(f).size() #in bytes
                fsize= sizeof_fmt(fsize) #convert bytes to human readable natural format
                self.tableWidget_files.setItem(currentRowCount , 1, QTableWidgetItem(f"{fsize}"))

            header = self.tableWidget_files.horizontalHeader()
            header.setSectionResizeMode(1, QHeaderView.ResizeMode.ResizeToContents)
        #if duplicate_list show qmessage with error "some files you are trying to add already are on the list" 
        # following files: [...duplicate_list...]  were not added again
        

    def add_files_via_dialog(self):
        print("dialog to add files")
        # filepath = QtWidgets.QFileDialog.getOpenFileName(self, 'Hey! Select a File')
        filenames, _ = QFileDialog.getOpenFileNames(
            None,
            "Select video files",
            "",
            "Video files(*.mp4 *.avi *.mkv *.flv *.avs *.ts *.wmv *.mov *.webm *m4v);; All files(*.*)",
        )
        self.add_files_to_table(filenames)
        

        


    
    
    def dragEnterEvent(self, event):
        if self.find_videos(event.mimeData()):
            event.accept()
        else:
            event.ignore()

    def dropEvent(self, event):
        #urls=event.mimeData().urls()
        urls = self.find_videos(event.mimeData())
        files = [u.toLocalFile() for u in urls]
        
        self.add_files_to_table(files)
        
    def find_videos(self, mimedata):
        urls = list()
        db = QMimeDatabase()
        for url in mimedata.urls():
            mimetype = db.mimeTypeForUrl(url)
            print(mimetype.name())
            if "video" in mimetype.name():
                urls.append(url)
        return urls
    

    def launch_abstCLI(self):
        #do the call here
        # validate process: files not empty, output path is consistent with the checkbox

        args=""
        outpath=self.output_path.text()
        fonts_dir=self.fontsdir_path.text()
        downscale=self.comboBox_downscale.currentText()
        param_files_str="::".join(f"{str(e)}" for e in self.param_files)
        args+=f"-crf {float(self.spinBox_crf.value())}"
        args+=" -preset "+ self.comboBox_preset.currentText()
        args+= " -tune "+self.comboBox_tune.currentText()
        
        
        args+= " -audio "+self.comboBox_audio.currentText()
        args+=f" -qaac_quality {int(self.spinBox_audio_quality.value())}"
        args+= "  -subpriority "+self.comboBox_subsettings.currentText()
        if downscale != "original":
            args+= " -auto_resize "+(self.comboBox_downscale.currentText()).replace('p', '')
            
            
        if outpath != "":
            args += f" -output_destination \"{outpath}\" " 
        if fonts_dir != "":
            args += f" -fonts_dir \"{fonts_dir}\" " 
        if len(param_files_str)==0:
            return
        args += f" -fi \"{param_files_str}\" " 
        
        print(f"gather params and launch CLI output: {outpath}  files {param_files_str} {args}" )
        
        
        # >start /wait "MyWin" "D:\apps\fansub-tools\abst-dev\script.exe" -crf 22
        # https://stackoverflow.com/questions/154075/using-the-start-command-with-parameters-passed-to-the-started-program
        # or cd to that dir then launch
        
        
        
        # str_cmd=f"start /wait \"ABST Encoder\" \"{proc}\"  {args} "
        str_cmd=f"start \"ABST Encoder\" \"CMD\" /K {PROC_REL}  {args} ^& pause"
        

        print(str_cmd)
        
        subprocess.Popen(str_cmd, shell=True)
        
        # QProcess.startDetached(str_cmd)
        # process = subprocess.Popen(str_cmd, shell=True,
        #             stdin=None, stdout=subprocess.PIPE, stderr=None, close_fds=True)
        

def report_crash(exc_type, exc_value, exc_tb):
    """Never die silently again.

    A --windowed build has nowhere to print a traceback to, so an exception on
    the startup path just made the process vanish with no feedback at all.
    Write it next to the exe and, if Qt is up, put it on screen.
    """
    text = "".join(traceback.format_exception(exc_type, exc_value, exc_tb))
    sys.stderr.write(text)
    try:
        with open(os.path.join(APP_DIR, "abst_error.log"), "w", encoding="utf-8") as f:
            f.write(text)
    except OSError:
        pass
    try:
        QtWidgets.QMessageBox.critical(
            None, "ABST failed to start",
            "ABST hit an unexpected error and could not start.\n\n"
            f"{exc_type.__name__}: {exc_value}\n\n"
            "Details were saved to abst_error.log next to ABST.exe.")
    except Exception:
        pass


if __name__ == '__main__':
    sys.excepthook = report_crash

    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-v","--version", help="show gui version", action="store_true")
    args = parser.parse_args()
    if args.version:
        print("Gui Version:", GUI_VERSION)
        sys.exit()

    # Anchor the process to the app folder before anything loads a resource.
    # themes/*.qss, lang/*.qm, abst_settings.ini and abst_cli.exe are all
    # referenced by relative path, so they only resolve if we are standing here.
    try:
        os.chdir(APP_DIR)
    except OSError:
        pass

    app = QtWidgets.QApplication(sys.argv)

    
    # Create class object
    window = AbstGUi()
    #window.setStyle("fusion")
    
    # apply_stylesheet(app, theme='light_blue.xml',invert_secondary=False)
    
    # Display the form
    window.show()

    # Start the event loop of the app or dialog box
    app.exec()