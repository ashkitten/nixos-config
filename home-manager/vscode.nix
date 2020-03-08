{ pkgs, ... }:

let
  vscodeExtUniqueId = "vadimcn.vscode-lldb";
  version = "1.5.0";
  vscode-lldb = pkgs.vscode-utils.buildVscodeExtension {
    name = "${vscodeExtUniqueId}-${version}";
    inherit vscodeExtUniqueId;
    src = pkgs.fetchurl {
      name = "${vscodeExtUniqueId}.zip";
      url = "https://github.com/vadimcn/vscode-lldb/releases/download/v${version}/codelldb-${pkgs.system}.vsix";
      sha256 = "0751s41sglc553nfjfpxa4g65a855k3mqw1ydmq11zxl3l0pr8x6";
    };
    buildInputs = with pkgs; [ python35 autoPatchelfHook ];
  };

  vscode = pkgs.vscode-with-extensions.override {
    vscodeExtensions = with pkgs.vscode-extensions; [
      vscode-lldb

      vscodevim.vim
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "rust";
        publisher = "rust-lang";
        version = "0.7.0";
        sha256 = "16n787agjjfa68r6xv0lyqvx25nfwqw7bqbxf8x8mbb61qhbkws0";
      }
      {
        name = "fairyfloss";
        publisher = "nopjmp";
        version = "0.0.6";
        sha256 = "1pg5ywzflak4qdvzf1g8q2540i57n31f93ac6lc7ds1hbg5zk27b";
      }
      {
        name = "crates";
        publisher = "serayuzgur";
        version = "0.4.7";
        sha256 = "1r8ywmdiy7xxq27hkjglh29hvs0c2yz5g9x1laasp43sdi056spl";
      }
      {
        name = "better-toml";
        publisher = "bungcip";
        version = "0.3.2";
        sha256 = "08lhzhrn6p0xwi0hcyp6lj9bvpfj87vr99klzsiy8ji7621dzql3";
      }
      {
        name = "nix";
        publisher = "bbenoist";
        version = "1.0.1";
        sha256 = "0zd0n9f5z1f0ckzfjr38xw2zzmcxg1gjrava7yahg5cvdcw6l35b";
      }
      {
        name = "nix-env-selector";
        publisher = "arrterian";
        version = "0.1.1";
        sha256 = "0fbpldyk7p3apvndhjzil4442czdgk7jgl96nl5kkdmqk4x7basm";
      }
    ];
  };
in
  {
    home.packages = [ vscode ];
  }
