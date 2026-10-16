// Paired daily bars (rides and rentals, or ride and rental revenue), as in the Figma charts.
// The values are also listed in a visually hidden table for screen readers.
import { count } from './format';

export interface BarDay {
  label: string;
  a: number;
  b: number;
}

/** Round an axis maximum up to 1 / 2 / 3 / 5 × 10ⁿ. */
export function niceMax(v: number) {
  if (v <= 0) return 10;
  const p = 10 ** Math.floor(Math.log10(v));
  for (const m of [1, 2, 3, 5, 10]) if (m * p >= v) return m * p;
  return 10 * p;
}

export function PairedBars({
  days,
  maxA,
  maxB,
  height,
  barWidth,
  gap,
  axis,
  caption,
  names,
}: {
  days: BarDay[];
  maxA: number;
  maxB: number;
  height: number;
  barWidth: number;
  gap: number;
  /** Left-axis labels, top to bottom. */
  axis: [string, string, string];
  caption: string;
  names: [string, string];
}) {
  return (
    <figure className="m-0">
      <div className="flex" style={{ height }}>
        <div aria-hidden className="flex w-9 flex-col justify-between text-[9px] text-sub">
          {axis.map((a, i) => (
            <span key={i}>{a}</span>
          ))}
        </div>
        <svg
          aria-hidden
          className="ml-3 flex-1 border-b border-line"
          preserveAspectRatio="none"
          viewBox={`0 0 ${days.length * 100} ${height}`}
          height={height}
        >
          {days.map((d, i) => {
            const cx = i * 100 + 50;
            const ha = Math.min(1, d.a / maxA) * height;
            const hb = Math.min(1, d.b / maxB) * height;
            return (
              <g key={i}>
                <rect
                  x={cx - gap / 2 - barWidth}
                  y={height - ha}
                  width={barWidth}
                  height={ha}
                  fill="#191919"
                />
                <rect
                  x={cx + gap / 2}
                  y={height - hb}
                  width={barWidth}
                  height={hb}
                  fill="#f6c200"
                />
              </g>
            );
          })}
        </svg>
      </div>
      <div aria-hidden className="mt-2.5 ml-12 flex">
        {days.map((d) => (
          <span key={d.label} className="flex-1 text-center text-[9px] text-sub">
            {d.label}
          </span>
        ))}
      </div>
      <table className="sr-only">
        <caption>{caption}</caption>
        <thead>
          <tr>
            <th scope="col">Day</th>
            <th scope="col">{names[0]}</th>
            <th scope="col">{names[1]}</th>
          </tr>
        </thead>
        <tbody>
          {days.map((d) => (
            <tr key={d.label}>
              <th scope="row">{d.label}</th>
              <td>{count(d.a)}</td>
              <td>{count(d.b)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </figure>
  );
}

export function Legend({ items }: { items: [string, string][] }) {
  return (
    <ul className="flex gap-[18px]">
      {items.map(([color, label]) => (
        <li key={label} className="flex items-center gap-1.5 text-[10px] text-sub">
          <span aria-hidden className="size-2 rounded-[2px]" style={{ background: color }} />
          {label}
        </li>
      ))}
    </ul>
  );
}
