# AWS account access

- Delegate any task that inspects an AWS account, organization, deployed resource,
  deployment, configuration, log, metric, or operational state to `aws-readonly`.
- Do not run account-connected AWS CLI commands from the primary agent. The
  `aws-readonly` agent owns that workflow. Approved profiles are names prefixed with
  `opencode-` or profiles whose configured `sso_role_name` is exactly
  `OpenCode-AdministratorAccess`, regardless of profile name.
  Granted profiles also qualify when their name contains `OpenCode-AdministratorAccess`
  and `granted_sso_role_name` is exactly `OpenCode-AdministratorAccess`; validate the
  configured `granted_sso_account_id` before use. Their existing credential process may
  run through the normal AWS CLI/SDK credential chain, never directly or for export.
  Local profile discovery may inspect all profile names and non-secret SSO metadata
  in `~/.aws/config` to identify these profiles; never dump the full file or credentials.
- The primary agent may use AWS documentation tools directly for general documentation
  questions that do not require access to the user's accounts.
- Keep AWS investigations read-only. Never fall back to default, ambient, or
  unapproved credentials when delegation fails or access is denied. Administrator
  profiles do not authorize mutations or automatic privilege escalation.
- AWS mutations belong only to the `aws-mutating` subagent. Never invoke it proactively:
  the user must explicitly name `@aws-mutating` or use `/aws-apply` for the specific
  operation. A general request to deploy, migrate, fix, or clean up is not sufficient.
  An explicit invocation may approve an otherwise unapproved, exactly named profile
  for that one operation only. The mutation agent must verify its configured role,
  account, and STS identity before use; this does not expand global profile approval
  or permit primary/read-only agents to use the exception profile.
- The primary agent and `aws-readonly` must remain read-only even when the user has
  authorized `aws-mutating` for a separate operation.
- Authentication recovery belongs to `aws-readonly`: when an approved profile's SSO
  token is missing or expired, it must run browser-based `aws sso login` for the
  profile's configured session, wait for the user to approve it, and retry the original
  operation. The primary agent must not send the user away to authenticate manually
  unless browser login fails, is cancelled, or times out.
- If the relevant account is unclear, let `aws-readonly` discover candidate accounts;
  ask the user only when ambiguity remains.

## Browser authentication preference

- Always open authentication windows in Chromium's Personal profile (`Default`)
  so the user's password-manager extension is available.
- Open sign-in URLs with `chromium --profile-directory=Default <url>`; do not use
  incognito, temporary browser data directories, or account-specific profiles.
- For AWS SSO, use `aws sso login --no-browser` with the approved profile/session,
  open its authorization URL in that Personal profile, and wait for completion.
