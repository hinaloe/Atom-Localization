module.exports =
    loadLocalization: () ->
        languages = require("../languages.json")
        selection = atom.config.get("localization.CurrentLanguage")

        if selection == "Default"
            return
        for l in languages[process.platform]
            if l["language"] == selection
                selection=l['path']
                dict = require(selection)
                walker = (currentMenu, transMenu)->
                  for i in currentMenu
                    if transMenu[i.label] != undefined
                      if transMenu[i.label]["submenu"] != undefined and i["submenu"] != undefined
                        walker(i.submenu, transMenu[i.label]["submenu"])
                      i.label = transMenu[i.label]["value"]
                walker(atom.menu.template, dict.menu)
                atom.menu.update()

    addMenu: () ->
        languages = require("../languages.json")
        for menu in atom.menu.template
            if menu.label == "Packages" || "&Packages"
                submenu = {label: "Localization", submenu: []}
                for lang in languages[process.platform]
                    l = lang["language"]
                    p = lang['path']
                    item = {label: l, command: "localization:#{ l }"}
                    atom.workspaceView.command("localization:#{ l }",null,{data:l},((e)=>
                        atom.config.set("localization.CurrentLanguage", e.data)
                        atom.reload()
                        ))
                    submenu.submenu.push(item)
                menu.submenu.push(submenu)

    activate: (state) ->

        @addMenu()

        setTimeout( ( (father)->
            if not atom.config.get("localization.CurrentLanguage")
              atom.config.set("localization.CurrentLanguage", "Default")
            father.loadLocalization()
          )
        ,300,this)
        setTimeout( ( (father)->
            if not atom.config.get("localization.CurrentLanguage")
              atom.config.set("localization.CurrentLanguage", "Default")
            father.loadLocalization()
          )
        ,1000,this)
