import { defineRailway, github, project, service } from "railway/iac";

// Matches the live Railway project (checked 2026-11-12). Nothing applies this
// file automatically; keep it in step with Railway if you change settings there.
export default defineRailway(() => {
  // The site: nginx serving the apps, portal, guide and bridge (root Dockerfile).
  // Rebuilds only when files that end up on the site change, not for README or
  // workflow edits.
  const craftSuite = service("craft-suite", {
    source: github("tedmelnick/craft-suite-railway", { branch: "main", checkSuites: false }),
    build: { watchPatterns: ["/Dockerfile", "/nginx/**", "/portal/**", "/bridge/**"] },
    replicas: { sfo: 1 },
  });

  // Craft Relay: MCP endpoint + bridge WebSocket for agent control of the
  // suite's browser tabs. Same repo, server/ subdirectory (its own Dockerfile).
  // Rebuilds only when server/ changes.
  const craftRelay = service("craft-relay", {
    source: github("tedmelnick/craft-suite-railway", { branch: "main", checkSuites: false }),
    rootDirectory: "server",
    build: { watchPatterns: ["/server/**"] },
    replicas: { sfo: 1 },
  });

  return project("craft-suite", {
    variables: { managed: false },
    resources: [craftSuite, craftRelay],
  });
});
