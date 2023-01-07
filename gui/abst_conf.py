from PyQt5.QtCore import QFileInfo
import configparser


"""
[UI]
Lang = 45
Theme = yes
"""
configfile='abst_settings.ini'

class ABSTConfig ():
    def __init__(self,conf_path=None):
        if conf_path:
            self.configfile = conf_path
        else:
            self.configfile = configfile
        self.UI_section = 'UI'
        self.config = configparser.ConfigParser()
        #if file exists
        if QFileInfo(self.configfile).exists():
            self.config.read(self.configfile)
            if self.config.has_option(self.UI_section,"Lang"): 
                self.ui_lang = self.config[self.UI_section]['Lang']
            else:
                self.ui_lang=None
            if self.config.has_option(self.UI_section,"Theme"): 
                self.ui_theme = self.config[self.UI_section]['Theme']
            else:
                self.ui_theme=None
        else:
            self.ui_lang =None
            self.ui_theme=None
    def save_conf(self):
        c = dict()
        if self.ui_theme: c["Theme"]=self.ui_theme
        if self.ui_lang: c["Lang"]=self.ui_lang

        self.config["UI"]=c
        with open(self.configfile, 'w') as cfile:
            self.config.write(cfile)
    def update_lang(self,lang):
        self.ui_lang=lang
        self.save_conf()
    def update_theme(self,theme):
        self.ui_theme=theme
        self.save_conf()

if __name__ == '__main__':
    con= ABSTConfig()
    con.update_lang("ar")
    con.update_theme("Dark")