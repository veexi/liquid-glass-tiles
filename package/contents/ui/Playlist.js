.pragma library

function localUrl(value) {
    var path = String(value || "").trim();
    if (path.indexOf("file://") === 0)
        return path;
    if (path.charAt(0) === "/")
        return "file://" + path.split("/").map(function(part) { return encodeURIComponent(part); }).join("/");
    return "";
}

function parse(serialized) {
    try {
        var values = JSON.parse(serialized || "[]");
        if (!Array.isArray(values)) return [];
        var result = [];
        for (var i = 0; i < values.length; ++i) {
            if (typeof values[i] !== "string") continue;
            var url = localUrl(values[i]);
            if (url && result.indexOf(url) < 0) result.push(url);
        }
        return result;
    } catch (error) { return []; }
}
