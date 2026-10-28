import { Plugin } from "@opencode/plugin";
import { Ttfx } from "./rpc.js";
import { createBroker } from "./broker.js";
import { toolDefinition } from "./tool.js";
import { serverHandlers } from "./bridge.js";

export default Plugin.define({
  id: "dotfiles.ttfx",
  async setup(ctx) {
    if (ctx.options.enabled === false) return;
    let broker;
    const rpc = await ctx.rpc.register(Ttfx, serverHandlers({
      claim: (input) => broker.claim(input), report: (input) => broker.report(input),
    }));
    broker = createBroker({ emit: (name, data) => rpc.events.emit(name, data) });
    const tools = await ctx.tool.transform((editor) => {
      editor.add(toolDefinition(ctx, broker));
    });
    return async () => { broker.dispose(); await tools.dispose(); await rpc.dispose(); };
  },
});
