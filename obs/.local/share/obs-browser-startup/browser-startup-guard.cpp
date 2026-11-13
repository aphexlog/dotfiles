// ##############################################################################
// Browser Panel API and Dependencies
// ##############################################################################

#include "browser-panel.hpp"

#include <chrono>
#include <memory>
#include <thread>

// ##############################################################################
// OBS Module Registration
// ##############################################################################

OBS_DECLARE_MODULE()

MODULE_EXPORT const char *obs_module_name(void)
{
  return "Browser Startup Guard";
}

MODULE_EXPORT const char *obs_module_description(void)
{
  return "Initialize browser docks before OBS restores their saved layout";
}

bool obs_module_load(void)
{
  return true;
}

// ##############################################################################
// Browser Initialization Before Dock Restoration
// ##############################################################################

void obs_module_post_load(void)
{
  // OBS 32.2.2 can post CEF tasks while restoring docks before CEF is ready.
  // Use the browser plugin's panel API after all modules have been loaded.
  std::unique_ptr<QCef> browser(obs_browser_init_panel());
  if (!browser || browser->initialized())
    return;

  browser->init_browser();
  const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(20);
  while (!browser->initialized() && std::chrono::steady_clock::now() < deadline)
    std::this_thread::sleep_for(std::chrono::milliseconds(20));

  blog(browser->initialized() ? LOG_INFO : LOG_WARNING,
       "[browser-startup-guard] Browser ready before dock restoration: %s",
       browser->initialized() ? "yes" : "no (initialization timed out)");
}
