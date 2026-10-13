# AWS account access

- Delegate any task that inspects an AWS account, organization, deployed resource,
  deployment, configuration, log, metric, or operational state to `aws-readonly`.
- Do not run account-connected AWS CLI commands from the primary agent. The
  `aws-readonly` agent owns that workflow and may use only profiles prefixed with
  `opencode-`.
- The primary agent may use AWS documentation tools directly for general documentation
  questions that do not require access to the user's accounts.
- Keep AWS investigations read-only. Never fall back to default, ambient, or
  non-`opencode-*` credentials when delegation fails or access is denied.
- AWS mutations belong only to the `aws-mutating` subagent. Never invoke it proactively:
  the user must explicitly name `@aws-mutating` or use `/aws-apply` for the specific
  operation. A general request to deploy, migrate, fix, or clean up is not sufficient.
- The primary agent and `aws-readonly` must remain read-only even when the user has
  authorized `aws-mutating` for a separate operation.
- Authentication recovery belongs to `aws-readonly`: when an approved profile's SSO
  token is missing or expired, it must run browser-based `aws sso login` for the
  profile's configured session, wait for the user to approve it, and retry the original
  operation. The primary agent must not send the user away to authenticate manually
  unless browser login fails, is cancelled, or times out.
- If the relevant account is unclear, let `aws-readonly` discover candidate accounts;
  ask the user only when ambiguity remains.
