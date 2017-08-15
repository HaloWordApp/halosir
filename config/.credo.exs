%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "web/", "apps/"],
        excluded: []
      },
      color: true,
      checks: [
        {Credo.Check.Readability.MaxLineLength, false},
      ]
    }
  ]
}
