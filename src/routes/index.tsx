import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowRight, Check, X } from "lucide-react";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Narrative Lens — See how coverage differs, measurably" },
      {
        name: "description",
        content:
          "Compare how outlets cover the same news event. Narrative Lens visualizes measurable changes in language, sourcing, emphasis, and perspective — never a verdict.",
      },
      { property: "og:title", content: "Narrative Lens — Comparative media analysis" },
      {
        property: "og:description",
        content:
          "A media-literacy dashboard for comparing coverage across outlets and over time.",
      },
    ],
  }),
  component: Landing,
});

function Landing() {
  return (
    <div>
      {/* HERO */}
      <section className="border-b border-rule">
        <div className="mx-auto grid max-w-7xl gap-12 px-6 py-20 lg:grid-cols-12 lg:py-28">
          <div className="lg:col-span-8">
            <p className="eyebrow">Media Literacy · Vol. 1</p>
            <h1 className="headline mt-6 text-5xl leading-[0.98] sm:text-6xl lg:text-7xl">
              See how the same story is <em className="text-accent not-italic">told differently</em>.
            </h1>
            <p className="mt-8 max-w-2xl font-serif text-xl leading-relaxed text-ink-muted">
              Instead of deciding what's true, Narrative Lens visualizes measurable
              changes in language, sourcing, emphasis, and perspective across outlets
              and over time.
            </p>
            <div className="mt-10 flex flex-wrap gap-3">
              <Link
                to="/analyze"
                className="group inline-flex items-center gap-2 rounded-md bg-primary px-5 py-3 text-sm font-medium text-primary-foreground transition-colors hover:bg-accent"
              >
                Try a sample analysis
                <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5" />
              </Link>
              <Link
                to="/methodology"
                className="inline-flex items-center gap-2 rounded-md border border-rule px-5 py-3 text-sm font-medium hover:bg-secondary"
              >
                How we measure
              </Link>
            </div>
          </div>
          <aside className="lg:col-span-4 lg:border-l lg:border-rule lg:pl-8">
            <p className="eyebrow">In this issue</p>
            <ul className="mt-4 space-y-4 text-sm">
              {[
                ["01", "Source Attribution Ratio"],
                ["02", "Agency Framing"],
                ["03", "Language Intensity"],
                ["04", "Perspective Coverage Matrix"],
                ["05", "Headline Diff (FrameShift Replay)"],
                ["06", "Narrative Evolution Timeline"],
              ].map(([n, t]) => (
                <li key={n} className="flex gap-3 border-b border-rule pb-3">
                  <span className="font-mono text-xs text-ink-muted">{n}</span>
                  <span className="font-serif">{t}</span>
                </li>
              ))}
            </ul>
          </aside>
        </div>
      </section>

      {/* WHAT WE DO / DON'T */}
      <section className="mx-auto max-w-7xl px-6 py-20">
        <p className="eyebrow">The Standard</p>
        <h2 className="headline mt-3 text-4xl sm:text-5xl">What we do — and don't do.</h2>
        <p className="mt-4 max-w-2xl text-ink-muted">
          Narrative Lens is a lens, not a judge. Our outputs are observations you can inspect,
          not conclusions we've drawn for you.
        </p>

        <div className="mt-10 grid gap-6 md:grid-cols-2">
          <div className="paper-card p-8">
            <p className="eyebrow text-accent">We do not</p>
            <ul className="mt-6 space-y-4">
              {[
                "Label articles as biased, misleading, or propaganda",
                "Rate outlets on a left–right political spectrum",
                "Decide which account of events is true",
                "Suppress, downrank, or flag any coverage",
              ].map((t) => (
                <li key={t} className="flex gap-3 text-sm">
                  <X className="mt-0.5 h-4 w-4 flex-shrink-0 text-accent" />
                  <span>{t}</span>
                </li>
              ))}
            </ul>
          </div>
          <div className="paper-card p-8">
            <p className="eyebrow">We do</p>
            <ul className="mt-6 space-y-4">
              {[
                "Surface who is quoted — officials vs. independent voices",
                "Compare sentence agency: active vs. passive framing",
                "Measure emotional load, certainty, and urgency in language",
                "Show which perspectives appear or are missing per outlet",
                "Replay how headlines changed over time",
              ].map((t) => (
                <li key={t} className="flex gap-3 text-sm">
                  <Check className="mt-0.5 h-4 w-4 flex-shrink-0 text-success" />
                  <span>{t}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      {/* CTA STRIP */}
      <section className="border-y border-rule bg-secondary/50">
        <div className="mx-auto flex max-w-7xl flex-col items-start justify-between gap-6 px-6 py-14 sm:flex-row sm:items-center">
          <div>
            <p className="eyebrow">Front page</p>
            <p className="headline mt-2 text-3xl">
              Open the sample: Riverside Housing Block Evictions.
            </p>
          </div>
          <Link
            to="/analyze"
            className="inline-flex items-center gap-2 rounded-md bg-primary px-5 py-3 text-sm font-medium text-primary-foreground hover:bg-accent"
          >
            Open sample dashboard <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
      </section>
    </div>
  );
}
