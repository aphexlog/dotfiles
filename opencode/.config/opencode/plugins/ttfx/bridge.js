// Keep RPC replies explicitly location-scoped. The public generic endpoint
// returns { output }; do not confuse it with an HTTP response or .data wrapper.
export async function callBridge(client, method, input, location) {
  const result = await client.rpc.call(
    { rpcID: "ttfx", method, input, location },
    { signal: AbortSignal.timeout(5000) },
  );
  return result.output;
}

// OpenCode's Promise plugin adapter requires Promise-returning RPC handlers.
export function serverHandlers(broker) {
  return {
    claim: async (input) => broker.claim(input),
    report: async (input) => broker.report(input),
  };
}
