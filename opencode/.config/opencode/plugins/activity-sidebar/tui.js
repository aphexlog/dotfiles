import { Plugin } from "@opencode/plugin/tui";
import { jsx } from "@opentui/solid/jsx-runtime";
import { createMemo } from "solid-js";
import { activityLines, latestActivity } from "./stats.js";

export default Plugin.define({
  id: "dotfiles.activity-sidebar",
  setup(context) {
    return context.ui.slot({
      prepend: "sidebar.content",
      render(props) {
        const stats = createMemo(() => latestActivity(
          context.data.session.message.list(props.sessionID),
        ));
        return jsx("box", {
          flexDirection: "column",
          marginBottom: 1,
          children: [
            jsx("text", {
              fg: context.theme.text.base,
              children: jsx("b", { children: "Latest activity" }),
            }),
            jsx("text", {
              fg: context.theme.text.base,
              get children() {
                return activityLines(stats(), context.data.session.status(props.sessionID));
              },
            }),
          ],
        });
      },
    });
  },
});
