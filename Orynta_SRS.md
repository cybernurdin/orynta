# ORYNTA — Software Requirements Specification (Build Edition)
**Version 2.0 — Development-Ready**
**For:** National Competition for the Best ICT Project, ICT Innovation Week 2026 (Cameroon)
**Theme alignment:** Protecting Cyberspace from the Misuse of Artificial Intelligence and Promoting Digital Patriotism

---

## 0. How to Use This Document

This SRS is written to be handed directly to a development tool or team (e.g. Claude Code) to scaffold and build Orynta. Every functional area includes: what to build, suggested tech, data shape, and acceptance criteria. Where a decision is still open (pricing, exact hosting provider, team names), it is marked `[DECISION NEEDED]` — do not invent these silently; surface them.

### 0.1 Alignment with Competition Evaluation Criteria

| # | Criterion | Where it's addressed in this SRS |
|---|---|---|
| 1 | Relevance | §1 Problem & Context |
| 2 | Innovation | §1.3, §3 (feature bundle no competitor offers together) |
| 3 | Technical feasibility | §2 Architecture, §4 Tech Stack, §9 Build Phases |
| 4 | Socio-economic impact | §1, §8 Success Metrics |
| 5 | Business model | §10 (cross-referenced; full detail in Project Overview doc) |
| 6 | Use of AI | §5 AI/ML Systems (named models, justified use, not decorative) |
| 7 | Digital patriotism & cybersecurity | §6 Security, Data Protection & Digital Sovereignty |
| — | Scalability & deployment (final pitch) | §9.4, §11 |

---

## 1. Problem & Context

Agriculture employs 70%+ of Cameroon's workforce and ~90% of the rural population but contributes only ~15% of GDP. ~2 million smallholder farms produce ~80% of national food consumption, operating with no practical soil testing, no reliable disease ID, and no localized weather-to-planting guidance. Post-harvest losses run 15–40%. The gap is not lack of agronomic knowledge in the world — it's that the knowledge never reaches the farmer, in their language, on their device, at the moment of decision.

### 1.1 Target Users (Personas)
- **Primary — Smallholder Farmer ("Mama Ngozi", West Region tomato/maize grower):** basic Android phone, intermittent data, limited literacy, decision-critical need at planting/spraying time.
- **Secondary — Cooperative Manager:** oversees 20–200 farmers, may hold a shared sensor, wants aggregated visibility.
- **Secondary — Agronomist/Extension Officer:** reviews AI-escalated cases, supports multiple cooperatives.
- **Tertiary — Input Supplier:** fertilizer/pesticide seller wanting qualified referrals.
- **Tertiary — Administrator:** manages platform content, users, regional rollout.

### 1.2 Core User Journeys (build these first)
1. Farmer opens app → scans soil photo → gets soil type + confidence + ranked crop list.
2. Farmer scans a leaf → gets diagnosis + confidence + treatment + nearest supplier.
3. Farmer checks home screen → sees this week's + this month's weather translated into a planting/spraying action.
4. Farmer lists produce for sale → sees indicative price trend → gets matched to a buyer/cooperative.
5. Low-confidence case → auto-routes to agronomist queue in the web portal → agronomist responds → farmer notified.

### 1.3 What Makes This Different (innovation basis)
No existing single product combines: camera-based soil + disease diagnosis, hyperlocal seasonal advisory, input-supplier referral, market linkage, and offline-first bilingual delivery, upgradeable to a shared BLE soil sensor without app redesign. Individually these exist (AgroCares, Plantix); the bundle, and the Cameroon-specific calibration path, does not.

---

## 2. System Architecture

```
┌─────────────────────────────┐
│   Mobile App (Android-first) │  Offline-capable, local DB, camera pipeline
└───────────────┬──────────────┘
                │ HTTPS/REST (delta sync, compressed payloads)
┌───────────────▼──────────────┐
│   API Gateway / App Layer     │  AuthN/AuthZ, routing, rate limiting
└───────────────┬──────────────┘
        ┌────────┼────────────┬───────────────┐
┌───────▼─────┐ ┌▼───────────┐ ┌▼────────────┐ ┌▼─────────────┐
│ AI/ML Service│ │ Core Domain│ │ Weather      │ │ SMS Gateway   │
│ (inference)  │ │ Services   │ │ Integration  │ │ (alerts)      │
└──────────────┘ └─────┬──────┘ └──────────────┘ └───────────────┘
                        │
                ┌───────▼────────┐
                │  Data Layer     │  Postgres (relational) + object storage (images)
                └───────┬────────┘
                        │
                ┌───────▼────────┐
                │   Web Portal    │  Agronomists / Cooperatives / Admin
                └─────────────────┘
```

**Design principle:** the AI/ML service is a pluggable module. Camera-based inference and (future) BLE-sensor inference both write to the same `soil_scan` table via the same API contract — the recommendation engine doesn't care which source produced the reading, only its confidence level. This is what lets Phase 2 hardware plug in without backend rework.

---

## 3. Functional Requirements

### 3.1 Soil Assessment & Crop Recommendation
| ID | Requirement | Priority |
|---|---|---|
| FR-1.1 | Capture soil photo, run on-device pre-processing (crop/normalize) before upload | Must |
| FR-1.2 | Cloud inference returns soil type (clay/sandy/loam/silt/mixed) + fertility indicator + confidence score (0–100) | Must |
| FR-1.3 | Combine with farmer-entered plot location, prior crop, season → ranked crop list (top 3–5) with plain-language rationale | Must |
| FR-1.4 | Never display an estimate without its confidence band (High/Medium/Low badge, color-coded) | Must |
| FR-1.5 | Bluetooth (BLE) sensor pairing flow; when paired, sensor reading supersedes photo estimate as primary source | Should (Phase 2) |
| FR-1.6 | Save scans per plot; show trend over time (soil health score history) | Should |

### 3.2 Leaf & Crop Health Diagnosis
| ID | Requirement | Priority |
|---|---|---|
| FR-2.1 | Capture leaf/plant photo → return probable pest/disease + confidence | Must |
| FR-2.2 | Return treatment guidance: recommended product class, dosage range, safety notes (PPE, re-entry interval) | Must |
| FR-2.3 | If confidence < threshold (`[DECISION NEEDED: default 70%]`), auto-create an escalation case in agronomist queue | Must |
| FR-2.4 | Anonymized, geotagged (region-level, not exact GPS) diagnosis feeds a regional heatmap | Should |
| FR-2.5 | Heatmap entries require either (a) high AI confidence + no conflicting reports, or (b) agronomist confirmation, before being marked "verified" — unverified reports are visually distinct | **Must** (anti-disinformation control, see §6.4) |

### 3.3 Weather & Planting Advisory
| ID | Requirement | Priority |
|---|---|---|
| FR-3.1 | Weekly + monthly forecast by farmer location (admin unit-level, e.g. Department) | Must |
| FR-3.2 | Seasonal outlook (rain onset/length estimate) | Must |
| FR-3.3 | Template-based translation engine: forecast → action sentence (e.g. "Good window to spray Thursday; rain expected Saturday") | Must |
| FR-3.4 | SMS delivery of critical alerts when app hasn't synced in > X hours `[DECISION NEEDED: threshold]` | Should |

### 3.4 Input Supplier & Market Linkage
| ID | Requirement | Priority |
|---|---|---|
| FR-4.1 | Recommend specific product categories (not brand-locked at MVP) based on scan results | Must |
| FR-4.2 | Supplier directory with location, product list, referral button | Should |
| FR-4.3 | Farmer produce listing (crop, qty, location, ready-date) | Should |
| FR-4.4 | Indicative regional price trend view (chart) | Should |
| FR-4.5 | Buyer/cooperative contact + listing view | Could (post-MVP) |

### 3.5 Web Portal
| ID | Requirement | Priority |
|---|---|---|
| FR-6.1 | Agronomist case queue: view escalated diagnoses, respond, close case | Must |
| FR-6.2 | Role-based dashboards: Agronomist / Cooperative Manager / Admin / Supplier | Must |
| FR-6.3 | Admin: manage users, crop/treatment content library, regional configs, feature flags | Must |
| FR-6.4 | Regional soil-health & verified-disease heatmap (public-safe, anonymized) | Should |
| FR-6.5 | Audit log viewer (who changed what, when) for admins | Should |

### 3.6 Offline, Language & Accessibility
| ID | Requirement | Priority |
|---|---|---|
| FR-7.1 | Full offline capture + cached advisory content; background sync with conflict resolution (last-write-wins + server-timestamp arbitration) | Must |
| FR-7.2 | English + French at MVP; Pidgin/local-language string bundle + voice narration of results as a fast-follow | Must |
| FR-7.3 | Every core feature usable with photo-only input; sensor never a hard requirement | Must |
| FR-7.4 | UI: large touch targets, icon-first navigation, max 3 taps to any scan feature | Must |

---

## 4. Technology Stack (recommendation — confirm before scaffolding)

| Layer | Recommended | Why |
|---|---|---|
| Mobile app | **Flutter** (Dart) or **React Native** | Single codebase, strong offline/local-DB ecosystem, wide low-end Android device support. Flutter has an edge on custom offline-camera UI performance. |
| Local on-device storage | SQLite via Drift (Flutter) / WatermelonDB (RN) | Offline-first sync patterns are mature in both. |
| Backend API | **Node.js (NestJS)** or **Django REST Framework** | NestJS if team is JS-heavy (matches Flutter+Dart less, RN more); Django if team wants batteries-included admin + strong ORM for the web portal. `[DECISION NEEDED: pick based on team's existing skill]` |
| Database | PostgreSQL + PostGIS (for location queries) | Relational integrity for farmer/plot/scan data; PostGIS for "nearest supplier" queries. |
| Object storage | S3-compatible (AWS S3, or a Cameroon/Africa-region-compatible provider) | Image uploads, thumbnails first then full-res on demand. |
| AI/ML inference | **TensorFlow Lite** or **ONNX Runtime Mobile** for on-device fallback; **PyTorch**-trained models served via a small inference API for cloud path | Enables both online and (partial) offline inference. |
| Weather data | Third-party met API (e.g. Open-Meteo, or a national met service partnership) downscaled to admin-unit level | `[DECISION NEEDED: confirm data source + licensing]` |
| SMS gateway | Local telecom-aggregator API (MTN/Orange Cameroon SMS API, or Africa's Talking) | Prefer a provider with Cameroon coverage for reliability + cost + sovereignty optics. |
| Web portal | React + a component library (shadcn/ui or MUI) | Fast to build role-based dashboards. |
| Hosting | Africa-region cloud (e.g. AWS `af-south-1` Cape Town) **or** a Cameroon-based hosting/datacenter partner | See §6.2 — this is a scored criterion, decide deliberately and document the reasoning in the pitch. |
| CI/CD | GitHub Actions → containerized deploy (Docker) | Standard, cheap, demonstrable. |

---

## 5. AI/ML Systems (named, justified — not decorative)

Being specific here directly serves competition criterion 6 ("AI integrated in a relevant and justified manner").

### 5.1 Soil Type/Fertility Classifier
- **Task:** image classification, soil photo → {clay, sandy, loam, silt, mixed} + fertility band.
- **Approach:** transfer learning on a lightweight CNN backbone (MobileNetV3 or EfficientNet-Lite) — chosen for on-device/low-bandwidth feasibility.
- **Training data:** public soil-image datasets for pretraining; **local, agronomist-labelled samples from the West Region pilot** for fine-tuning and regional calibration (see §6.3).
- **Justification:** a rules-based color chart cannot capture texture/organic-matter visual cues reliably across lighting conditions; a trained classifier can, and improves as local data grows — this is where "AI" is more than a label.

### 5.2 Leaf Disease/Pest Classifier
- **Task:** image classification, leaf photo → disease/pest class + confidence.
- **Approach:** transfer learning on a CNN pretrained on public plant-disease datasets (e.g. PlantVillage-style), fine-tuned on Cameroon-relevant crops (tomato, maize, cassava — `[DECISION NEEDED: confirm priority crop list]`) using locally collected images.
- **Escalation logic:** confidence below threshold → routed to human agronomist, never auto-published as fact (see FR-2.3).

### 5.3 Recommendation Engine
- **Task:** combine soil result + location + season + crop history → ranked crop list; combine diagnosis + severity → treatment guidance.
- **Approach:** hybrid — a rules/knowledge-base layer (agronomist-authored logic, versioned as content, not code) plus a learned ranking layer once enough usage data exists. Start rules-first for auditability and explainability (important for trust and for judges who will ask "how does it decide?"), evolve toward ML ranking as data accumulates.
- **Justification:** decision support with a clear, explainable rationale — this is the "decision support" value the judging criteria explicitly ask about.

### 5.4 Weather-to-Action Translator
- **Task:** structured forecast → farmer-facing action sentence.
- **Approach:** template/NLG at MVP (deterministic, reliable, low compute); consider a small language model fine-tuned on agronomist-written examples as a fast-follow for more natural phrasing in multiple languages.

### 5.5 Model Governance
- Every model is **versioned**; every prediction stored with the model version that produced it (auditability).
- Confidence thresholds are configurable per model via admin portal, not hardcoded.
- Quarterly (or milestone-based) retraining cadence as regional data grows — documented, not ad hoc.

---

## 6. Security, Data Protection & Digital Sovereignty

This section directly answers competition criterion 7. Build it in from day one, not as a bolt-on.

### 6.1 Data Protection
- All traffic over TLS 1.2+; no plaintext endpoints.
- Passwords hashed with Argon2id (never store plaintext or reversible hashes).
- Farmer PII (name, phone, precise GPS) encrypted at rest; access logged.
- Role-Based Access Control (RBAC): Farmer / Cooperative Manager / Agronomist / Supplier / Admin, enforced at the API layer, not just UI-hidden.
- Data-subject rights implemented as real features, not just policy text: a farmer can view, export, and request deletion of their data from within the app — this directly satisfies Article 15(4) of the competition rules regarding data access/rectification/deletion.
- Public-facing heatmap and market data are **aggregated and location-generalized** (region/department level, never exact plot GPS) before publication.

### 6.2 Digital Sovereignty & Local Hosting
- Default recommendation: host primary infrastructure in an **Africa-region data center** (e.g. AWS `af-south-1`) or a **Cameroon-based hosting partner**, explicitly to reduce latency for local users and reduce dependency on infrastructure outside the region. `[DECISION NEEDED: finalize provider and state the rationale in the pitch — this is directly scored]`.
- Avoid unnecessary foreign SaaS dependencies where a capable regional/local alternative exists (e.g. SMS gateway via a Cameroon telecom aggregator rather than a generic global provider, where feasible).
- Document data residency clearly in a public-facing privacy notice.

### 6.3 Regional Model Calibration (also a feasibility & trust point)
- Soil composition varies by geography; a model trained in one region will not be accurate elsewhere without recalibration. Each new region's rollout includes a local sample-collection step before launch — stated explicitly, not glossed over. This protects against overclaiming "works everywhere" without evidence, which a technically literate jury will probe.

### 6.4 Anti-Disinformation Controls (theme-critical)
The regional disease heatmap is public-facing and therefore a disinformation surface if unmanaged. Controls:
- Two-tier trust model: **AI-flagged** (visually distinct, e.g. hatched marker) vs **Agronomist-verified** (solid marker) — never presented identically.
- Rate-limiting and anomaly detection on report submission (prevent coordinated false-report flooding of one area).
- Agronomist review required before any report changes a region's *public* status from "unconfirmed" to "confirmed outbreak."
- Full audit trail of who/what verified each entry.

### 6.5 Application Security Hygiene
- Input validation and file-type/size sanitization on every image upload.
- Dependency vulnerability scanning in CI (e.g. `npm audit` / `pip-audit` / Dependabot).
- Rate limiting and basic bot/abuse protection on public endpoints.
- Secrets managed via environment/secret manager, never committed to source control.
- Basic incident-response note: who is notified, how quickly, on a suspected breach — even a one-paragraph policy is worth having for the jury.

---

## 7. Data Model (core entities)

```
User(id, name, phone, email, password_hash, role, language_pref, cooperative_id, created_at)
Cooperative(id, name, region, department, manager_user_id)
Plot(id, owner_user_id, region, department, gps_lat, gps_lng, size_ha, created_at)
SoilScan(id, plot_id, source[photo|sensor], captured_at, soil_type, ph, moisture, npk_json,
         fertility_band, confidence, model_version, image_url)
CropRecommendation(id, soil_scan_id, crop_name, rank, rationale_text)
LeafDiagnosis(id, plot_id, captured_at, image_url, predicted_class, confidence,
              model_version, escalation_status[none|pending|resolved], verified_by_user_id)
WeatherAdvisory(id, region, window[week|month|season], issued_at, advisory_text, raw_forecast_json)
Supplier(id, name, region, gps_lat, gps_lng, product_categories[])
MarketListing(id, farmer_user_id, crop_name, quantity, unit, ready_date, status, price_expectation)
HeatmapEntry(id, region, disease_class, status[unconfirmed|confirmed], report_count, last_updated)
AuditLog(id, actor_user_id, action, target_type, target_id, timestamp)
```

Notes:
- `region`/`department` fields use Cameroon's administrative divisions consistently across tables — decide the canonical list early (`[DECISION NEEDED]`).
- `model_version` on every AI-derived row is mandatory — non-negotiable for auditability.

---

## 8. Non-Functional Requirements & Success Metrics

| NFR | Target |
|---|---|
| On-device capture-to-preview | < 5 seconds |
| Cloud inference round trip (connected) | < 10 seconds |
| Offline core features | 100% functional with zero connectivity |
| Uptime target (post-pilot) | 99% `[DECISION NEEDED: confirm SLA ambition]` |
| Scalability | Stateless API services, horizontally scalable; pilot (hundreds) → tens of thousands without re-architecture |
| Accessibility | 3-tap max to any core scan feature; icon-first; voice narration fast-follow |

**Success metrics to instrument from day one** (feeds directly into "socio-economic impact" evidence for the jury): active farmers/plots, scans performed, diagnoses confirmed vs. escalated, average confidence trend over time, reported crop-loss reduction (self-reported survey at pilot), listings sold via marketplace, cooperatives onboarded.

---

## 9. Build Phases

### 9.1 Phase 0 — Foundation (pre-pitch priority)
- Finalize tech stack decisions marked `[DECISION NEEDED]` above.
- Scaffold mobile app shell (navigation, offline DB, camera capture flow) + backend API skeleton + auth.
- Stand up Postgres schema from §7.

### 9.2 Phase 1 — MVP for Demo (this is what needs to exist before the final pitch — 20/100 points ride on this)
- Soil scan (photo → mock or lightweight-model inference) end-to-end.
- Leaf diagnosis (photo → inference) end-to-end.
- Weather advisory (static/template, real API optional at this stage) displayed on home screen.
- Offline capture + sync working demonstrably (airplane-mode demo is a strong jury moment).
- Basic security: auth, encrypted storage, RBAC skeleton — enough to genuinely answer jury questions, not just claim it.
- **Goal:** a real, live, tappable demo on a phone — even with a smaller/simpler model than the final vision — beats slides every time for the "product demonstration" criterion.

### 9.3 Phase 2 — Post-selection depth
- Web portal (agronomist queue, admin).
- SMS fallback, marketplace listings.
- Model retraining pipeline with locally collected data.
- Voice/Pidgin support.

### 9.4 Phase 3 — Scale (this feeds the "scalability & deployment strategy" criterion directly)
- BLE soil sensor hardware integration.
- Second-region calibration and rollout.
- Regional → national expansion plan with named regions and timeline `[DECISION NEEDED: draft the actual timeline for the pitch deck]`.
- Longer-term: cross-border expansion (e.g. neighboring countries) contingent on new regional soil calibration — framed honestly as future work, not a current claim.

---

## 10. Business Model Cross-Reference
Full detail lives in the Project Overview document. In short: free core app; cooperative/NGO-purchased sensors and seats; affordable premium subscription; supplier/buyer partnership referral revenue. `[DECISION NEEDED: real price points before the pitch — "affordable" is not sufficient at final-pitch stage]`.

## 11. Open Decisions Checklist (resolve before/soon after Phase 0)
- [ ] Backend framework: NestJS vs Django
- [ ] Hosting provider + region (state publicly, this is scored)
- [ ] SMS gateway provider
- [ ] Weather data source/licensing
- [ ] Confidence thresholds for auto-escalation
- [ ] Priority crop list for MVP disease model
- [ ] Canonical Cameroon admin-region list for `region`/`department` fields
- [ ] Real subscription/pricing numbers
- [ ] Rollout timeline (regions + dates) for scalability slide
