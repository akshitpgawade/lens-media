
-- Enum for headline source
CREATE TYPE public.headline_source AS ENUM ('wayback','live');

-- Outlets
CREATE TABLE public.outlets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  url text NOT NULL,
  authority_tier text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.outlets TO anon, authenticated;
GRANT ALL ON public.outlets TO service_role;
ALTER TABLE public.outlets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public read outlets" ON public.outlets FOR SELECT USING (true);

-- Events
CREATE TABLE public.events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  summary text NOT NULL,
  first_reported_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.events TO anon, authenticated;
GRANT ALL ON public.events TO service_role;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public read events" ON public.events FOR SELECT USING (true);

-- Articles
CREATE TABLE public.articles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  outlet_id uuid NOT NULL REFERENCES public.outlets(id) ON DELETE CASCADE,
  url text NOT NULL,
  headline text NOT NULL,
  published_at timestamptz NOT NULL,
  full_text text NOT NULL
);
GRANT SELECT ON public.articles TO anon, authenticated;
GRANT ALL ON public.articles TO service_role;
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public read articles" ON public.articles FOR SELECT USING (true);

-- Headline snapshots
CREATE TABLE public.headline_snapshots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  article_id uuid NOT NULL REFERENCES public.articles(id) ON DELETE CASCADE,
  headline_text text NOT NULL,
  captured_at timestamptz NOT NULL,
  source public.headline_source NOT NULL
);
GRANT SELECT ON public.headline_snapshots TO anon, authenticated;
GRANT ALL ON public.headline_snapshots TO service_role;
ALTER TABLE public.headline_snapshots ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public read headline_snapshots" ON public.headline_snapshots FOR SELECT USING (true);

CREATE TABLE public.signals_source_attribution (
  article_id uuid PRIMARY KEY REFERENCES public.articles(id) ON DELETE CASCADE,
  official_ratio numeric NOT NULL,
  independent_ratio numeric NOT NULL
);
GRANT SELECT ON public.signals_source_attribution TO anon, authenticated;
GRANT ALL ON public.signals_source_attribution TO service_role;
ALTER TABLE public.signals_source_attribution ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public read ssa" ON public.signals_source_attribution FOR SELECT USING (true);

CREATE TABLE public.signals_agency_framing (
  article_id uuid PRIMARY KEY REFERENCES public.articles(id) ON DELETE CASCADE,
  agency_score numeric NOT NULL,
  example_phrases jsonb NOT NULL DEFAULT '[]'::jsonb
);
GRANT SELECT ON public.signals_agency_framing TO anon, authenticated;
GRANT ALL ON public.signals_agency_framing TO service_role;
ALTER TABLE public.signals_agency_framing ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public read saf" ON public.signals_agency_framing FOR SELECT USING (true);

CREATE TABLE public.signals_language_intensity (
  article_id uuid PRIMARY KEY REFERENCES public.articles(id) ON DELETE CASCADE,
  emotional_score numeric NOT NULL,
  certainty_score numeric NOT NULL,
  urgency_score numeric NOT NULL
);
GRANT SELECT ON public.signals_language_intensity TO anon, authenticated;
GRANT ALL ON public.signals_language_intensity TO service_role;
ALTER TABLE public.signals_language_intensity ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public read sli" ON public.signals_language_intensity FOR SELECT USING (true);

CREATE TABLE public.stakeholders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  name text NOT NULL,
  role text NOT NULL,
  first_appeared_at timestamptz
);
GRANT SELECT ON public.stakeholders TO anon, authenticated;
GRANT ALL ON public.stakeholders TO service_role;
ALTER TABLE public.stakeholders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public read stakeholders" ON public.stakeholders FOR SELECT USING (true);

CREATE TABLE public.coverage_matrix (
  article_id uuid NOT NULL REFERENCES public.articles(id) ON DELETE CASCADE,
  stakeholder_id uuid NOT NULL REFERENCES public.stakeholders(id) ON DELETE CASCADE,
  present boolean NOT NULL,
  PRIMARY KEY (article_id, stakeholder_id)
);
GRANT SELECT ON public.coverage_matrix TO anon, authenticated;
GRANT ALL ON public.coverage_matrix TO service_role;
ALTER TABLE public.coverage_matrix ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public read coverage_matrix" ON public.coverage_matrix FOR SELECT USING (true);

-- =============== SEED ===============
DO $$
DECLARE
  ev_id uuid := gen_random_uuid();
  o_globe uuid := gen_random_uuid();
  o_metro uuid := gen_random_uuid();
  o_bulletin uuid := gen_random_uuid();
  o_dispatch uuid := gen_random_uuid();
  a_globe uuid := gen_random_uuid();
  a_metro uuid := gen_random_uuid();
  a_bulletin uuid := gen_random_uuid();
  a_dispatch uuid := gen_random_uuid();
  s_resident uuid := gen_random_uuid();
  s_police uuid := gen_random_uuid();
  s_mayor uuid := gen_random_uuid();
  s_witness uuid := gen_random_uuid();
  s_expert uuid := gen_random_uuid();
  s_ngo uuid := gen_random_uuid();
BEGIN
  INSERT INTO public.outlets(id,name,url,authority_tier) VALUES
    (o_globe,'The Globe Register','https://globe.example','legacy'),
    (o_metro,'Metro Daily','https://metro.example','regional'),
    (o_bulletin,'City Bulletin','https://bulletin.example','independent'),
    (o_dispatch,'Riverside Dispatch','https://dispatch.example','community');

  INSERT INTO public.events(id,title,summary,first_reported_at) VALUES
    (ev_id,
     'Riverside Housing Block Evictions',
     'On the morning of March 14, 2026, roughly 40 households in the Riverside neighborhood were removed from a mixed-use housing block during a court-ordered eviction. Coverage varied significantly across outlets.',
     '2026-03-14 07:15:00+00');

  INSERT INTO public.stakeholders(id,event_id,name,role,first_appeared_at) VALUES
    (s_police, ev_id, 'Metropolitan Police', 'official', '2026-03-14 07:40:00+00'),
    (s_mayor,  ev_id, 'City Mayor''s Office', 'official', '2026-03-14 09:10:00+00'),
    (s_resident, ev_id, 'Displaced Residents', 'affected', '2026-03-14 11:20:00+00'),
    (s_witness, ev_id, 'Neighborhood Witnesses', 'witness', '2026-03-14 12:00:00+00'),
    (s_expert, ev_id, 'Housing Policy Experts', 'expert', '2026-03-15 08:00:00+00'),
    (s_ngo, ev_id, 'Tenant Advocacy NGO', 'advocacy', '2026-03-15 14:30:00+00');

  INSERT INTO public.articles(id,event_id,outlet_id,url,headline,published_at,full_text) VALUES
    (a_globe, ev_id, o_globe,   'https://globe.example/riverside',    'Court-Ordered Eviction Carried Out at Riverside Complex', '2026-03-14 10:12:00+00', 'Authorities executed a court order Tuesday morning...'),
    (a_metro, ev_id, o_metro,   'https://metro.example/riverside',    'Riverside Families Removed From Homes as Police Move In', '2026-03-14 11:05:00+00', 'Dozens of families were removed from their homes...'),
    (a_bulletin, ev_id, o_bulletin,'https://bulletin.example/riverside','40 Households Displaced in Pre-Dawn Riverside Sweep', '2026-03-14 12:40:00+00', 'Advocates say residents were given less than 48 hours notice...'),
    (a_dispatch, ev_id, o_dispatch,'https://dispatch.example/riverside','"We Had Nowhere To Go": Neighbors Describe Riverside Morning', '2026-03-14 15:20:00+00', 'Neighbors gathered on the sidewalk described a chaotic morning...');

  INSERT INTO public.headline_snapshots(article_id, headline_text, captured_at, source) VALUES
    (a_globe, 'Eviction Notice Enforced at Riverside Housing Block',                    '2026-03-14 08:00:00+00', 'wayback'),
    (a_globe, 'Court-Ordered Eviction Carried Out at Riverside Complex',                '2026-03-14 10:12:00+00', 'live'),
    (a_metro, 'Police Clear Riverside Housing Block',                                   '2026-03-14 09:30:00+00', 'wayback'),
    (a_metro, 'Riverside Families Removed From Homes as Police Move In',                '2026-03-14 11:05:00+00', 'live'),
    (a_bulletin, 'Residents Say They Were Given Hours To Leave Riverside',              '2026-03-14 10:45:00+00', 'wayback'),
    (a_bulletin, '40 Households Displaced in Pre-Dawn Riverside Sweep',                 '2026-03-14 12:40:00+00', 'live'),
    (a_dispatch, 'Neighbors Watch as Riverside Families Pack Belongings',               '2026-03-14 13:10:00+00', 'wayback'),
    (a_dispatch, '"We Had Nowhere To Go": Neighbors Describe Riverside Morning',        '2026-03-14 15:20:00+00', 'live');

  INSERT INTO public.signals_source_attribution(article_id, official_ratio, independent_ratio) VALUES
    (a_globe, 0.82, 0.18),
    (a_metro, 0.61, 0.39),
    (a_bulletin, 0.34, 0.66),
    (a_dispatch, 0.20, 0.80);

  INSERT INTO public.signals_agency_framing(article_id, agency_score, example_phrases) VALUES
    (a_globe,    0.28, '[{"text":"Residents were removed from the property","type":"passive"},{"text":"An eviction was carried out","type":"agentless"},{"text":"Officials confirmed the operation had concluded","type":"passive"}]'::jsonb),
    (a_metro,    0.55, '[{"text":"Police moved families out of the building","type":"active"},{"text":"Residents were escorted from their apartments","type":"passive"},{"text":"The city carried out the order","type":"active"}]'::jsonb),
    (a_bulletin, 0.74, '[{"text":"Officers removed 40 households","type":"active"},{"text":"The city displaced families before sunrise","type":"active"},{"text":"Residents said they were given hours, not days","type":"active"}]'::jsonb),
    (a_dispatch, 0.81, '[{"text":"Officers physically escorted people out","type":"active"},{"text":"A neighbor helped a mother carry her belongings","type":"active"},{"text":"The city acted on the order at 6 a.m.","type":"active"}]'::jsonb);

  INSERT INTO public.signals_language_intensity(article_id, emotional_score, certainty_score, urgency_score) VALUES
    (a_globe,    0.22, 0.78, 0.30),
    (a_metro,    0.48, 0.62, 0.55),
    (a_bulletin, 0.63, 0.55, 0.70),
    (a_dispatch, 0.81, 0.40, 0.72);

  INSERT INTO public.coverage_matrix(article_id, stakeholder_id, present) VALUES
    (a_globe, s_police, true),  (a_globe, s_mayor, true),  (a_globe, s_resident, false), (a_globe, s_witness, false), (a_globe, s_expert, true),  (a_globe, s_ngo, false),
    (a_metro, s_police, true),  (a_metro, s_mayor, true),  (a_metro, s_resident, true),  (a_metro, s_witness, false), (a_metro, s_expert, false), (a_metro, s_ngo, true),
    (a_bulletin, s_police, true),(a_bulletin, s_mayor, false),(a_bulletin, s_resident, true),(a_bulletin, s_witness, true),(a_bulletin, s_expert, true),(a_bulletin, s_ngo, true),
    (a_dispatch, s_police, false),(a_dispatch, s_mayor, false),(a_dispatch, s_resident, true),(a_dispatch, s_witness, true),(a_dispatch, s_expert, false),(a_dispatch, s_ngo, true);
END $$;
