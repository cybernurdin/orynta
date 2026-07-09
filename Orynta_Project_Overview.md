# ORYNTA — Project Overview
**Grow smarter, farm better**
A smartphone-first AI advisory platform for smallholder farmers in Cameroon.

---

## 1. Vision

Every Cameroonian smallholder farmer makes their most important decisions — what to plant, how to treat a sick crop, when to spray, where to sell — with a smartphone in their pocket and real, localized data behind the answer, not guesswork.

## 2. The Problem

Agriculture employs 70%+ of Cameroon's workforce and ~90% of the rural population, yet contributes only ~15% of national GDP. Nearly two million small family farms produce ~80% of the food Cameroonians eat, working with no practical soil testing, no reliable disease identification, and no localized weather-to-planting guidance. Post-harvest losses on staple and vegetable crops run 15–40% nationally. The knowledge needed to prevent most of this loss already exists in agronomy — it simply never reaches the farmer, in their language, on their device, at the moment the decision has to be made.

## 3. The Solution

Orynta turns a smartphone into a farmer's personal agronomist:
- **Scan** a soil sample and a plant leaf with the camera.
- **Understand** the soil type, fertility, and any disease/pest — in plain language, with a visible confidence level.
- **Plan** using weekly, monthly, and seasonal weather advisories translated into concrete planting/spraying actions.
- **Act** through in-app links to nearby input suppliers for recommended products, and to buyers when produce is ready.
- **Escalate** automatically to a human agronomist whenever the AI isn't confident — no farmer is left with a guess dressed up as certainty.

No lab visit. No hardware purchase required to start. A low-cost Bluetooth soil sensor is planned as a future, cooperative-shareable upgrade for farmers who want lab-grade precision — the software is architected today to accept it without redesign.

## 4. The Innovative Factor (one-line version for forms)

> Orynta is the first platform to combine camera-based soil and disease diagnosis, hyperlocal seasonal weather guidance, input-supplier linkage, and market access in a single offline-first, bilingual tool built for the Cameroonian smallholder — with a clear, non-redesign upgrade path to precision hardware.

## 5. Target Users & Beneficiaries

| Segment | Description | Estimated reach (West Region pilot) |
|---|---|---|
| Smallholder farmers | Primary users; basic Android phone, intermittent connectivity | `[DECISION NEEDED: pilot farmer count target]` |
| Women in agriculture | ~75% of Cameroon's agricultural workforce | Reached via voice-supported, cooperative-distributed access |
| Cooperative managers | Oversee 20–200 farmers each | Entry point for sensor-sharing model |
| Agronomists/extension officers | Review escalated AI cases | Multiplier — one officer supports many farmers via the portal |
| Input suppliers | Fertilizer/pesticide sellers | Referral partners |
| Produce buyers/cooperatives | Market-side counterpart | Marketplace participants |

## 6. How Orynta Generates Income

| Stream | Mechanism |
|---|---|
| Cooperative/NGO sales | Sensors and premium seats purchased or subsidized for member groups — one device serves many farmers |
| Premium subscription | Affordable upgrade: advanced market analytics, unlimited expert chat `[DECISION NEEDED: real price point]` |
| Supplier partnerships | Referral fee or listing fee from input suppliers reaching Orynta's farmer base |
| Buyer/marketplace partnerships | Transaction or access fee from produce buyers, once market-linkage volume justifies it |
| Core app | Always free for individual farmers — adoption is never gated by cost |

## 7. Competition Criteria — Explicit Self-Assessment

*(Kept honest and specific — a jury notices genuine self-awareness more than blanket claims.)*

| Criterion | How Orynta addresses it |
|---|---|
| **Relevance** | Directly targets a sourced, large-scale national problem (agriculture is 70%+ of the workforce; losses of 15–40% are well documented) |
| **Innovation** | Bundles features that exist separately elsewhere (soil scanners, disease apps) into one offline-first, Cameroon-calibrated product with a hardware upgrade path |
| **Technical feasibility** | Built on proven, accessible technology (mobile CV models, standard cloud backend, BLE); phased build plan matches a realistic MVP-first maturity level, not an overclaim |
| **Socio-economic impact** | Reduces post-harvest loss, improves input spending decisions, reaches women farmers specifically, creates local jobs (agronomist reviewers, field agents, supplier partnerships) |
| **Business model** | Freemium core, cooperative/NGO sales, supplier and buyer partnerships — diversified, not dependent on farmer wealth |
| **Use of AI** | Named, justified models (image classification for soil/disease, hybrid rules+ML recommendation engine) with visible confidence scoring and human escalation — not AI-as-decoration |
| **Digital patriotism & cybersecurity** | Encrypted data, RBAC, data-subject rights built into the app, anti-disinformation controls on the public disease heatmap, and a deliberate stance on regional/local hosting to reduce foreign infrastructure dependency |
| **Scalability & deployment** | West Region pilot → regional calibration model → phased national rollout, with cross-border potential as a stated future step, not a current claim |

## 8. Roadmap

| Phase | Timeframe | Milestone |
|---|---|---|
| Phase 0 | Now | Requirements & architecture finalized (this document + SRS); team assembled |
| Phase 1 | 0–4 months | MVP: photo-based soil + leaf diagnosis, weather advisory, offline-first, EN/FR — pilot with 1 West Region cooperative |
| Phase 2 | 4–8 months | Web portal, SMS fallback, basic marketplace, voice/Pidgin support |
| Phase 3 | 8–14 months | BLE soil sensor integration; second-region calibration |
| Phase 4 | 14+ months | Supplier partnerships at scale, market intelligence, public regional heatmap, national rollout planning |

## 9. Success Metrics

Active farmers and plots · scans performed · diagnoses confirmed vs. escalated · reported crop-loss reduction · produce sold through the platform · cooperatives onboarded · confidence-score trend over time (proxy for model improvement).

## 10. Team

`[DECISION NEEDED — required before submission]`

| Role | Name | Background |
|---|---|---|
| Product / Team Lead | — | — |
| App & Backend Development | — | — |
| Agronomy / Agricultural Lead | — | — |

## 11. Legal & Eligibility Notes (self-check before submission)

- [ ] Project holder(s) confirmed Cameroonian nationality and Cameroon residency
- [ ] Registering as a startup (new entity or new activity within an existing structure)
- [ ] Only one project submitted per person/startup
- [ ] No team member already attached to another competing project
- [ ] Registration form fields ready: startup/project presentation, problem/opportunity, innovative factor, summary, target/beneficiaries, income model, team profiles

## 12. Glossary

- **BLE** — Bluetooth Low Energy, used for the future soil sensor.
- **Confidence band** — visible High/Medium/Low indicator on every AI-generated result.
- **Offline-first** — core features work fully without an internet connection, syncing later.
- **Regional calibration** — tuning a model with real local soil/leaf samples before launching in a new area.
