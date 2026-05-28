# Creates an agent config string from a template
# Variables: @model@, @subagents_suffix@
{ template, model, suffix }:
let
  raw = builtins.readFile template;
  prompt = builtins.replaceStrings ["@model@" "@subagents_suffix@"] [model suffix] raw;
in
prompt
