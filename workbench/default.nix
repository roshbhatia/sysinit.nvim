{ fetchFromGitHub, vimUtils }:
{
  sysinit-reviewr = vimUtils.buildVimPlugin {
    pname = "reviewr.nvim";
    version = "0-unstable-2026-11-23";
    src = fetchFromGitHub {
      owner = "paul-enz";
      repo = "reviewr.nvim";
      rev = "0c97dcaabcca99b16bb6c68b0c1197e0e8ab08f6";
      hash = "sha256-V5E8wQf2OlFrtgug3z7chKE3gK9pg+mqjszFCn2ohWM=";
    };
  };

  sysinit-editor-workbench = vimUtils.buildVimPlugin {
    pname = "sysinit-editor-workbench";
    version = "1";
    src = ./.;
  };
}
