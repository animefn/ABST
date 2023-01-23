mkdir -Force gui\lang_src
#mkdir -Force gui\lang
#pylupdate5  .\gui\abst_ui.py .\gui\abst_gui.py  -ts gui\lang_src\english.ts
pylupdate5  .\gui\abst_ui.py .\gui\abst_gui.py  -ts gui\lang_src\arabic.ts
# pylupdate5 -noobsolete  .\gui\abst_ui.py .\gui\abst_gui.py  -ts gui\lang_src\arabic.ts   
pylupdate5  .\gui\abst_ui.py .\gui\abst_gui.py  -ts gui\lang_src\french.ts
# pylupdate5   -noobsolete .\gui\abst_ui.py .\gui\abst_gui.py  -ts gui\lang_src\french.ts 