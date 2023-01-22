
from PyQt5 import QtWidgets
from PyQt5.QtGui import *
from PyQt5.QtWidgets import QTableWidgetItem,QHeaderView,QFileDialog #,QWidget

from PyQt5.QtCore import QDir,QFileInfo,Qt,QMimeDatabase,QProcess, QSize,QTranslator,QCoreApplication


from abst_conf import ABSTConfig
import abst_ui

import sys
import subprocess
import webbrowser

# Future feauture: maybe someday dnd on widget only instead of window specially if we need DND for other things
#        https://stackoverflow.com/questions/71098302/drag-and-drop-files-to-qtablewidget
#        https://stackoverflow.com/questions/10264040/how-to-drag-and-drop-into-a-qtablewidget-pyqt





proc=r".\abst_cli.exe"
# proc=r"D:\apps\fansub-tools\abst-dev\script.exe"

GUI_VERSION=3



def change_material_style(stylename=""):
    if stylename=="":
        app.setStyleSheet ("")
        return
    app.setStyle("windowsvista")
    QDir.addSearchPath(f'icon_{stylename}', f"themes\{stylename}\icons")
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



class AbstGUi (QtWidgets.QMainWindow,abst_ui.Ui_MainWindow):
    def __init__(self, parent=None):
        
        # change_material_style("dark_teal")
        # change_material_style()

        CLI_VERSION=subprocess.check_output([proc, '-v'],shell=True).decode('utf-8').strip()
        CG_VERSION=f"{CLI_VERSION}g{GUI_VERSION}"
        CLI_latest,CG_latest=subprocess.check_output([proc, '-check_update'],shell=True).decode('utf-8').strip().split("[")[1].split("]")[0].split("g")
        
        super(AbstGUi, self).__init__(parent)
        ###
        self.conf= ABSTConfig()
        self.trans = QTranslator(self)
        
        


        theme= "modern light"
        lang= "English"
        if self.conf.ui_theme : theme = self.conf.ui_theme 
        if self.conf.ui_lang : lang = self.conf.ui_lang
        self.trans.load("lang_rls/arabic")
        
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
        # self.trans.load("lang_rls/french")
        
        # QtWidgets.QApplication.instance().installTranslator(self.trans)
        
        # tableWidget_files #use minimumSectionSize?
        # self.tableWidget_files.horizontalHeaderItem(0).setText("file")
        # self.tableWidget_files.horizontalHeaderItem(1).setText("size")
        ver_status='<br><span style=" color:#5AAB61;"><b>'+self.tr("latest")+'</b></span>'
        if CLI_latest>CLI_VERSION or CG_latest>CG_VERSION:
            ver_status='<br><span style=" color:#ff0000;"><b>'+self.tr("Please update")+'</b></span>'
        self.label_verNb.setText(CG_VERSION+ver_status)
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

        #self.retranslateUi()
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
        str_cmd=f"start \"ABST Encoder\" \"CMD\" /K {proc}  {args} ^& pause"
        

        print(str_cmd)
        
        subprocess.Popen(str_cmd, shell=True)
        
        # QProcess.startDetached(str_cmd)
        # process = subprocess.Popen(str_cmd, shell=True,
        #             stdin=None, stdout=subprocess.PIPE, stderr=None, close_fds=True)
        

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-v","--version", help="show gui version", action="store_true")
    args = parser.parse_args()
    if args.version:
        print("Gui Version:", GUI_VERSION)
        sys.exit()
    app = QtWidgets.QApplication(sys.argv)
    
    
    # Create class object
    window = AbstGUi()
    #window.setStyle("fusion")
    
    # apply_stylesheet(app, theme='light_blue.xml',invert_secondary=False)
    
    # Display the form
    window.show()

    # Start the event loop of the app or dialog box
    app.exec()