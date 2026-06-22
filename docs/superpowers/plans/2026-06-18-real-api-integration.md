# Real API Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace mock/demo API code with real DeepSeek pricing calls and real AMap location SDK integration boundaries.

**Architecture:** Keep API keys in one config file, keep pages free of HTTP/SDK implementation details, and route all external calls through `service/` classes. Remove mock pricing and simulated location controls from UI.

**Tech Stack:** HarmonyOS ArkTS, `@ohos.net.http`, AMap HarmonyOS NEXT location SDK, DeepSeek Chat Completions API, hvigor.

---

## File Structure

- Create `code/entry/src/main/ets/common/ApiConfig.ets`: API keys, base URLs, model name.
- Modify `code/entry/oh-package.json5`: add AMap common and location dependencies.
- Modify `code/entry/src/main/ets/entryability/EntryAbility.ets`: initialize AMap API key before SDK use.
- Modify `code/entry/src/main/ets/service/LocationService.ets`: use AMap single-location service and remove simulation methods.
- Modify `code/entry/src/main/ets/service/LlmPricingProvider.ets`: call DeepSeek HTTP API.
- Modify `code/entry/src/main/ets/service/PricingService.ets`: route to LLM provider only.
- Delete `code/entry/src/main/ets/service/MockPricingProvider.ets`.
- Modify `code/entry/src/main/ets/view/RegionRecommendPanel.ets`: remove demo area buttons.
- Modify `code/entry/src/main/ets/pages/Index.ets`: remove simulated location calls.
- Modify `code/scripts/verify-campus-market.mjs`: require real API markers and reject mock/simulated markers.

## Tasks

- [ ] Add failing verification requiring `ApiConfig`, DeepSeek model, AMap key initialization, no mock provider, and no `simulate*Location`.
- [ ] Add `ApiConfig.ets` with supplied keys and model `deepseek-v4-flash`.
- [ ] Add AMap dependencies to `entry/oh-package.json5`.
- [ ] Replace pricing provider with real DeepSeek HTTP JSON call.
- [ ] Route `PricingService` to `LlmPricingProvider` and delete `MockPricingProvider.ets`.
- [ ] Initialize AMap SDK key in `EntryAbility`.
- [ ] Replace `LocationService` simulation with AMap single-location call.
- [ ] Remove demo buttons and simulated calls from recommendation panel and homepage.
- [ ] Run `ohpm install` or build dependency resolution.
- [ ] Run verification script and hvigor build.
