{ pkgs, inputs, ... }:
let
  jail-nix = inputs.jail-nix;
  jail = jail-nix.lib.init pkgs;

  jailed-pi = jail "pi" pkgs.pi-coding-agent (with jail.combinators; [
    network
    mount-cwd
    (persist-home "pi")
    no-new-session
    time-zone

    (add-pkg-deps (with pkgs; [
      git
      nodejs
      ripgrep
      fd
      gnugrep
      findutils
      gnutar
      gzip
      which
    ]))

    (try-fwd-env "ANTHROPIC_API_KEY")
    (try-fwd-env "OPENAI_API_KEY")
    (try-fwd-env "OPENROUTER_API_KEY")
    (try-fwd-env "GOOGLE_API_KEY")
    (try-fwd-env "DEEPSEEK_API_KEY")
    (try-fwd-env "GROQ_API_KEY")
    (try-fwd-env "MISTRAL_API_KEY")
    (try-fwd-env "XAI_API_KEY")
    (try-fwd-env "CEREBRAS_API_KEY")
    (try-fwd-env "AZURE_OPENAI_API_KEY")
    (try-fwd-env "BEDROCK_API_KEY")
    (try-fwd-env "BEDROCK_API_KEY_ID")
    (try-fwd-env "PI_OFFLINE")
    (try-fwd-env "PI_SKIP_VERSION_CHECK")
    (try-fwd-env "PI_TELEMETRY")
    (try-fwd-env "PI_CODING_AGENT_DIR")
    (try-fwd-env "PI_CODING_AGENT_SESSION_DIR")
    (try-fwd-env "VISUAL")
    (try-fwd-env "EDITOR")
  ]);
in
{
  home.packages = [
    jailed-pi
    pkgs.nodejs
  ];
}
