
from PyQt5 import QtWidgets
from PyQt5.QtGui import *
from PyQt5.QtWidgets import QTableWidgetItem,QHeaderView,QFileDialog 

#from PyQt5.QtWidgets import QWidget
from PyQt5.QtCore import QDir,QFileInfo,Qt,QProcess
#from qt_material import apply_stylesheet
import webbrowser

from abst_conf import ABSTConfig
import sys
import abst_ui
import subprocess
## remaining challenges
# validate and accept (video files only) for drag and drop https://stackoverflow.com/questions/69627395/pyqt-drag-n-drop-hasformat
# maybe someday dnd on widget only instead of window
#        https://stackoverflow.com/questions/71098302/drag-and-drop-files-to-qtablewidget
#        https://stackoverflow.com/questions/10264040/how-to-drag-and-drop-into-a-qtablewidget-pyqt

#--remining booring task
# github actions
# best compilation mechaism (most compact? lightest?)

# save UI settings (theme,lang) [done]
# extract styles, etc [done]
# qt material design themes arrow issue [done]
# launch separate process [done]
# uniqueness of added files and compute file size[done]
# file dialogs ADD | picker folder [done]
# removal of selected items [done]



proc=r".\abst_cli.exe"
# proc=r"D:\apps\fansub-tools\abst-dev\script.exe"

GUI_VERSION=1


def change_material_style(stylename=""):
    if stylename=="":
        app.setStyleSheet ("")
        return
    app.setStyle("windowsvista")
    QDir.addSearchPath(f'icon_{stylename}', f"themes\{stylename}\icons")
    with open(f"themes/{stylename}/{stylename}.qss", 'r') as file:
            app.setStyleSheet ( file.read())
    # QDir.addSearchPath(f'icon_{stylename}', f"themes\{stylename}\icons")



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
        super(AbstGUi, self).__init__(parent)
        ###
        self.conf= ABSTConfig()
        theme= "modern light"
        if self.conf.ui_theme : theme = self.conf.ui_theme 
        change_style(theme)       
        ###
        self.setupUi(self)
        self.setAcceptDrops(True)
        
        
    
        self.param_files = set()
        self.spinBox_audio_quality.setEnabled(False) #renable later when deciding settings

        #video parameters
        # self.param_crf = None
        # self.param_preset =None
        # apply_stylesheet(self, theme='dark_blue.xml')
        # apply_stylesheet(self, theme='')
        
        #audio parameters
        
        
        # tableWidget_files #use minimumSectionSize?
        # self.tableWidget_files.horizontalHeaderItem(0).setText("file")
        # self.tableWidget_files.horizontalHeaderItem(1).setText("size")
        
        self.label_verNb.setText(CG_VERSION)
        self.tableWidget_files.setHorizontalHeaderLabels(['filename', 'size'])
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

        self.comboBox_audio.currentTextChanged.connect(self.audio_setting)
        
        self.comboBox_style.currentTextChanged.connect(change_style)
        self.comboBox_style.currentTextChanged.connect(self.conf.update_theme)
        self.comboBox_style.setCurrentText(theme)
        #do the same 3 lines for language
        #con.update_lang("ar")
    
        # self.checkBox_qtstyle.stateChanged.connect(change_qt_style)
        
        self.checkBox_outdir.stateChanged.connect(self.enable_disable_output) 
        
        self.pbtn_launchCLI.clicked.connect(self.launch_abstCLI)
        
        self.pbtn_update.clicked.connect(lambda: webbrowser.open('http://animefn.com'))
        self.pbtn_donate.clicked.connect(lambda: webbrowser.open('http://animefn.com'))


        

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
        self.spinBox_audio_quality.setEnabled(False)

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
        # out_path = QtWidgets.QFileDialog.getOpenFileName(self, 'Hey! Select a File')
        folderpath = QtWidgets.QFileDialog.getExistingDirectory(self, 'Select output Folder')
        self.output_path.setText(folderpath)

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
        #print(event.mimeData().data())
        if event.mimeData().hasUrls():
        # if event.mimeData().hasFormat("video/mp4"):
            event.accept()
        else:
            event.ignore()

    def dropEvent(self, event):
        files = [u.toLocalFile() for u in event.mimeData().urls()]
        
        self.add_files_to_table(files)
        # for f in files:
        #     print(f)
        #     #refactor to an add function
        #     self.tableWidget_files.insertRow(currentRowCount)
        #     self.tableWidget_files.setItem(currentRowCount , 0, QTableWidgetItem(f))

        #     self.tableWidget_files.setItem(currentRowCount , 1, QTableWidgetItem("0000MB"))
        #     header = self.tableWidget_files.horizontalHeader()
        #     header.setSectionResizeMode(1, QHeaderView.ResizeMode.ResizeToContents)

    def change_style(self,stylename):
        # pass
        print(stylename)
        if stylename== "dark":
            with open('dark_teal.qss', 'r') as file:
                print( "LOL")
                self.setStyleSheet ( file.read())
                QDir.addSearchPath('icon', 'theme')
        else:
            self.setStyleSheet ("")

    def launch_abstCLI(self):
        #do the call here
        # validate process: files not empty, output path is consistent with the checkbox

        args=""
        outpath=self.output_path.text()
        downscale=self.comboBox_downscale.currentText()
        param_files_str="::".join(f"{str(e)}" for e in self.param_files)
        args+=f"-crf {int(self.spinBox_crf.value())}"
        args+=" -preset "+ self.comboBox_preset.currentText()
        args+= " -tune "+self.comboBox_tune.currentText()
        
        
        args+= " -audio "+self.comboBox_audio.currentText()
        args+= "  -subpriority "+self.comboBox_subsettings.currentText()
        if downscale != "original":
            args+= " -auto_resize "+(self.comboBox_downscale.currentText()).replace('p', '')
        if outpath != "":
            args += f" -output_destination \"{outpath}\" " 
        if len(param_files_str)==0:
            return
        args += f" -f \"{param_files_str}\" " 
        
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
    
    

    # with open('dark_teal.qss', 'r') as file:
    # app.style_sheet = file.read()  #pyside6
        # app.setStyleSheet ( file.read())
    

    # Load icons
    # QDir.add_search_path('icon', 'theme') #pyside6
    # QDir.addSearchPath('icon', 'theme')

    # Create class object
    window = AbstGUi()
    #window.setStyle("fusion")
    
    # apply_stylesheet(app, theme='light_blue.xml',invert_secondary=False)
    
    # Display the form
    window.show()

    # Start the event loop of the app or dialog box
    app.exec()