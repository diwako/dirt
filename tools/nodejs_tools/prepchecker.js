/*
    Author: joko // Jonas
*/

const path = require("path");
const fs = require("fs");
const core = require("@actions/core");

const PREFIX = "dirt";

const projectFiles = [];
const prepedFunctions = [];
const ignoreFiles = [
  "addons/main/functions/fnc_var1.sqf",
  "addons/main/functions/fnc_fncName.sqf",
];
const ignoredFiles = [];

const commentRegex = /\/\*[\s\S]*?\*\/|([^\\:]|^)\/\/.*$/gm;
const prepRegex = /PREP\((\w+)\)|SUBPREP\((\w+),(\w+)\);|DFUNC\((\w+)\)/gm;
const funcPrep = /FUNC\((\w+)\)|EFUNC\((\w+),(\w+)\)/gm;

for (const file of ignoreFiles) {
  var temp = "";
  for (const p of file.split("/")) {
    temp = path.join(temp, p);
  }
  ignoredFiles.push(temp);
}

const requiredFunctionFiles = [];
let failedCount = 0;

function getDirFiles(p, module) {
  var files = fs.readdirSync(p);
  for (const file of files) {
    if (file.endsWith(".pbo")) continue;
    filePath = path.join(p, file);
    if (fs.lstatSync(filePath).isDirectory()) {
      if (module === "") {
        getDirFiles(filePath, file);
      } else {
        getDirFiles(filePath, module);
      }
    } else {
      var data = {
        path: filePath,
        module: module,
      };
      if (!projectFiles.includes(data)) projectFiles.push(data);
      getFunctions(filePath, module);
    }
  }
}

function getFunctions(file, module) {
  let content = fs.readFileSync(file, { encoding: "utf8", flag: "r" });
  content = content.replace(commentRegex, "");

  let match;
  while ((match = prepRegex.exec(content)) !== null) {
    // This is necessary to avoid infinite loops with zero-width matches
    if (match.index === prepRegex.lastIndex) {
      prepRegex.lastIndex++;
    }

    // The result can be accessed through the `m`-variable.
    for (let groupIndex = 0; groupIndex < match.length; groupIndex++) {
      const functionName = match[groupIndex];
      if (!functionName) continue;
      if (groupIndex != 0 && groupIndex != 2) {
        prepedFunctions.push(
          `${PREFIX}_${module}_fnc_${functionName}`.toLowerCase()
        );
        if (!match[2] && groupIndex != 3)
          requiredFunctionFiles.push(
            path.join(
              `addons`,
              `${module}`,
              `functions`,
              `fnc_${functionName}.sqf`
            )
          );
      } else if (groupIndex != 0 && groupIndex == 2) {
        requiredFunctionFiles.push(
          path.join(
            `addons`,
            `${module}`,
            `functions`,
            `${functionName}`,
            `fnc_${match[groupIndex + 1]}.sqf`
          )
        );
      }
    }
  }
}

function CheckFunctions() {
  for (const data of projectFiles) {
    if (ignoredFiles.includes(data.path)) continue;
    const index = requiredFunctionFiles.indexOf(data.path);
    if (index > -1) {
      requiredFunctionFiles.splice(index, 1);
    }

    let content = fs.readFileSync(data.path).toString();
    const lines = content.split("\n");
    content = content.replace(commentRegex, "");
    let match;
    while ((match = funcPrep.exec(content)) !== null) {
      // This is necessary to avoid infinite loops with zero-width matches
      if (match.index === funcPrep.lastIndex) {
        funcPrep.lastIndex++;
      }
      var fncName;
      if (match[1]) {
        fncName = `${PREFIX}_${data.module}_fnc_${match[1]}`;
      } else if (match[2] && match[3]) {
        fncName = `${PREFIX}_${match[2]}_fnc_${match[3]}`;
      }
      if (fncName) {
        if (!prepedFunctions.includes(fncName.toLowerCase())) {
          console.log(
            `Use of not Existing Functions: ${fncName} in ${data.path}`
          );
          var key;
          if (match[1]) {
            key = `FUNC(${match[1]})`;
          } else if (match[2] && match[3]) {
            key = `EFUNC(${match[2]},${match[3]})`;
          }
          var line = lines.findIndex((x) => x.includes(key));
          core.error(`Use of not Existing Functions: ${fncName}`, {
            file: data.path,
            startLine: line,
          });
          failedCount++;
        }
      }
    }
  }
}

getDirFiles("addons", "");
CheckFunctions();

for (const file of requiredFunctionFiles) {
  if (ignoredFiles.includes(file)) continue;
  failedCount++;
  console.log(`File ${file} Missing!`);
}
if (failedCount == 0) {
  console.log("No Errors in Found");
}
process.exit(failedCount);
