module.exports =
    config:
        CurrentLanguage:
            type: 'string'
            default: 'Default'
    loadLocalization: () ->
        languages = require("../languages.json")
        selection = atom.config.get("localization.CurrentLanguage")

        if selection == "Default"
            return
        for l in languages
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
            if menu.label == "Packages"
                submenu = {label: "Localization", submenu: []}
                for lang in languages
                    l = lang["language"]
                    p = lang['path']
                    item = {label: l, command: "localization:#{ p }"}
                    atom.workspaceView.command("localization:#{ p }",null,{data:l},((e)=>
                        atom.config.set("localization.CurrentLanguage", e.data)
                        atom.reload()
                        ))
                    submenu.submenu.push(item)
                menu.submenu.push(submenu)

    activate: (state) ->

        @addMenu()

        setTimeout( ( (father)->
            father.loadLocalization()
          )
        ,300,this)
        setTimeout( ( (father)->
            father.loadLocalization()
          )
        ,1000,this)
        atom.config.onDidChange 'localization.CurrentLanguage', ({newValue, oldValue}) =>
            # console.log("#{oldValue} => #{newValue}")
            @loadLocalization()
        return
