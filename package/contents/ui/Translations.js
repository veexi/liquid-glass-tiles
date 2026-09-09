.pragma library
.import "Catalogs.js" as Catalogs

function language(selection, preferredLanguages) {
    if (selection && selection !== "system")
        return selection;
    for (var i = 0; i < preferredLanguages.length; ++i) {
        var tag = preferredLanguages[i].replace(/_/g, "-").toLowerCase();
        if (tag === "zh" || tag === "zh-cn" || tag === "zh-sg" || tag.indexOf("zh-hans") === 0)
            return "zh_CN";
        if (tag === "en" || tag.indexOf("en-") === 0)
            return "en";
    }
    return "en";
}

function text(message, selection, preferredLanguages) {
    var catalog = Catalogs.messages[language(selection, preferredLanguages)];
    return catalog && catalog[message] ? catalog[message] : message;
}
