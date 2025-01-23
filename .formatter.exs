[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"],
  line_length: 98,
  plugins: [Phoenix.LiveView.HTMLFormatter, Styler],
  subdirectories: ["priv/*/migrations"]
]
