import { walkSync } from "https://deno.land/std@0.224.0/fs/walk.ts";

const templateSearchPattern = /\$\{template\}/g;
const templateReplacement = 'TEMPLATE';
const replacePath = './replaced/';
const srcPath = './template/'

Deno.chdir(srcPath);
const directory = Array.from(walkSync("."));
Deno.chdir('../');

directory.forEach((entry) => {
  const replacePathName = replacePath + entry.path.replace(templateSearchPattern, templateReplacement)
  const srcPathName = srcPath + entry.path
  
  if (entry.isDirectory) {
    
    Deno.mkdirSync(replacePathName, {recursive: true})
  }
  if (entry.isFile) {
    Deno.writeTextFileSync(replacePathName, Deno.readTextFileSync(srcPathName).replace(templateSearchPattern, templateReplacement))
  }
})
