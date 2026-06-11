const Discord = require("discord.js");
const client = new Discord.Client();
const fs = require("fs");

let hwids = [];

// GitHub stores the HWID list as a file – we'll keep it simple with an environment variable
// Instead of reading a file, we'll store the list in an environment variable (secrets)
const allowedEnv = process.env.ALLOWED_HWIDS || "";
if (allowedEnv.length > 0) {
    hwids = allowedEnv.split(",").map(h => h.trim());
}

function buildLoader() {
    const fs = require("fs");
    let master = fs.readFileSync("./master.lua", "utf8");

    let hwidTable = "local allowedHWIDs = {\n";
    for (const hwid of hwids) {
        hwidTable += `    "${hwid}",\n`;
    }
    hwidTable += "}\n";

    let script = master.replace("--HWID_PLACEHOLDER--", hwidTable);

    const password = process.env.PASSWORD || "default";
    let hex = "";
    for (let i = 0; i < script.length; i++) {
        const b = script.charCodeAt(i);
        const k = password.charCodeAt(i % password.length);
        hex += (b ^ k).toString(16).padStart(2, "0");
    }

    const loader = `local key = "${password}"\nlocal enc = "${hex}"\n\nlocal function xorDecode(hex, key)\n    local out = ""\n    for i = 1, #hex, 2 do\n        local b = tonumber(hex:sub(i, i+1), 16)\n        local k = key:byte((math.floor((i-1)/2) % #key) + 1)\n        out = out .. string.char(b ~ k)\n    end\n    return out\nend\n\nlocal dec = xorDecode(enc, key)\nlocal fn, err = loadstring(dec)\nif fn then\n    fn()\nelse\n    game.Players.LocalPlayer:Kick("Script error: " .. err)\nend`;
    return loader;
}

client.on("message", (msg) => {
    if (!msg.content.startsWith("!") || msg.author.bot) return;

    const args = msg.content.slice(1).trim().split(/ +/);
    const command = args.shift().toLowerCase();

    if (command === "addhwid") {
        const hwid = args[0];
        if (!hwid) return msg.reply("❌ Usage: !addhwid <hwid>");
        if (!hwids.includes(hwid)) {
            hwids.push(hwid);
            // Update environment variable (Vercel will need a redeploy to update permanently, but for now we just update the in-memory list)
            // For permanent storage, we'll need to use Vercel's API to update env vars.
            // For simplicity, we'll just keep the list in memory and also save to a temporary file.
            fs.writeFileSync("/tmp/hwids.json", JSON.stringify(hwids));
            const loader = buildLoader();
            msg.channel.send("✅ HWID added. New loader:");
            msg.channel.send(loader, { split: true });
        } else {
            msg.reply("⚠️ That HWID is already in the list.");
        }
    } else if (command === "removehwid") {
        const hwid = args[0];
        if (!hwid) return msg.reply("❌ Usage: !removehwid <hwid>");
        const index = hwids.indexOf(hwid);
        if (index > -1) {
            hwids.splice(index, 1);
            fs.writeFileSync("/tmp/hwids.json", JSON.stringify(hwids));
            const loader = buildLoader();
            msg.channel.send("✅ HWID removed. New loader:");
            msg.channel.send(loader, { split: true });
        } else {
            msg.reply("⚠️ That HWID is not in the list.");
        }
    } else if (command === "listhwid") {
        if (hwids.length === 0) return msg.reply("No HWIDs stored.");
        msg.reply("Stored HWIDs:\n" + hwids.join("\n"));
    } else if (command === "getloader") {
        const loader = buildLoader();
        msg.channel.send("Current loader:");
        msg.channel.send(loader, { split: true });
    }
});

client.login(process.env.TOKEN);