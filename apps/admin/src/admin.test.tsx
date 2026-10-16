import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

import { App } from './app';
import { DemoAdminBackend } from './data/demo';
import { makeQueryClient } from './data/queries';
import { searchTarget } from './ui/shell';
import { initI18n } from './i18n';

initI18n('en');

// 14 Oct 2026 · 09:41 in Douala, the time the Figma frames show.
const NOW = new Date('2026-10-14T08:41:00Z');

function start(path: string, signedIn = true) {
  const repo = new DemoAdminBackend({ now: NOW, latency: 0, signedIn });
  const client = makeQueryClient();
  client.setDefaultOptions({ queries: { retry: false, refetchInterval: false } });
  render(<App repo={repo} client={client} now={NOW} initialPath={path} />);
  return { repo, user: userEvent.setup() };
}

// jsdom has no <dialog> methods.
beforeAll(() => {
  HTMLDialogElement.prototype.showModal ??= function (this: HTMLDialogElement) {
    this.setAttribute('open', '');
  };
  HTMLDialogElement.prototype.close ??= function (this: HTMLDialogElement) {
    this.removeAttribute('open');
  };
});

test('the demo admin signs in and lands on the overview', async () => {
  const { user } = start('/overview', false);
  expect(await screen.findByRole('heading', { name: 'Sign in to operations' })).toBeInTheDocument();
  await user.click(screen.getByRole('button', { name: 'Sign in' }));
  expect(await screen.findByRole('heading', { name: 'Operations overview' })).toBeInTheDocument();
  expect(screen.getAllByText('Nadine Eyenga').length).toBeGreaterThan(0);
  expect((await screen.findAllByText(/^1\s284$/)).length).toBeGreaterThan(0);
});

test('a wrong password is refused', async () => {
  const { user } = start('/overview', false);
  const password = await screen.findByLabelText('Password');
  await user.clear(password);
  await user.type(password, 'nope');
  await user.click(screen.getByRole('button', { name: 'Sign in' }));
  expect(await screen.findByText('Email or password is incorrect.')).toBeInTheDocument();
});

test('rides filter by tab and search, and a row opens the ride', async () => {
  const { user } = start('/rides');
  const table = await screen.findByRole('table', { name: 'Rides' });
  expect(within(table).getAllByRole('row')).toHaveLength(1 + 8);
  await user.click(screen.getByRole('button', { name: /On trip · 3/ }));
  expect(within(table).getAllByRole('row')).toHaveLength(1 + 3);
  await user.click(screen.getByRole('button', { name: /On trip · 3/ }));
  await user.type(
    screen.getByRole('searchbox', { name: 'Search ride ID, rider or driver' }),
    'RD-1042',
  );
  const rows = within(table).getAllByRole('row');
  expect(rows).toHaveLength(2);
  await user.click(rows[1]!);
  expect(await screen.findByRole('heading', { name: 'Ride RD-1042' })).toBeInTheDocument();
});

test('a refund is requested from the ride detail', async () => {
  const { user } = start('/rides/ride-RD-1042');
  await user.click(await screen.findByRole('button', { name: 'Review refund' }));
  const dialog = await screen.findByRole('dialog', { name: 'Refund for RD-1042' });
  const amount = within(dialog).getByLabelText('Amount (FCFA)');
  await user.clear(amount);
  await user.type(amount, '1000');
  await user.click(within(dialog).getByRole('button', { name: 'Request refund' }));
  expect(await within(dialog).findByText('Fill in every field.')).toBeInTheDocument();
  await user.type(
    within(dialog).getByLabelText('Reason (shared with finance)'),
    'Driver took a longer route',
  );
  await user.click(within(dialog).getByRole('button', { name: 'Request refund' }));
  await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument());
  expect((await screen.findAllByText(/1 000 FCFA refund requested/)).length).toBeGreaterThan(0);
});

test('approving the first application in the verification queue', async () => {
  const { user } = start('/drivers');
  const panel = await screen.findByRole('region', { name: 'Application review' });
  expect(within(panel).getByText('DR-032 · Submitted 14 Oct, 08:40')).toBeInTheDocument();
  // Sending it back needs a note first.
  await user.click(within(panel).getByRole('button', { name: 'Reject & request resubmission' }));
  expect(
    within(panel).getByText('Add a note so the driver knows what to fix.'),
  ).toBeInTheDocument();
  await user.click(within(panel).getByRole('button', { name: 'Approve application' }));
  expect(
    await screen.findByText('Arnaud Fouda is approved and can go online.'),
  ).toBeInTheDocument();
});

test('a safety case is assigned, then resolved with a note', async () => {
  const { user } = start('/safety?case=SA-091');
  const panel = await screen.findByRole('region', { name: 'SA-091 · Rider safety concern' });
  await user.click(within(panel).getByRole('button', { name: 'Assign to me' }));
  expect(await screen.findByText('SA-091 updated')).toBeInTheDocument();
  await waitFor(() => expect(screen.getAllByText(/Nadine assigned/).length).toBeGreaterThan(0));

  const fresh = await screen.findByRole('region', { name: 'SA-091 · Rider safety concern' });
  await user.click(within(fresh).getByRole('button', { name: 'Resolve incident' }));
  expect(
    within(fresh).getByText('Write the resolution in the notes before resolving.'),
  ).toBeInTheDocument();
  await user.type(
    within(fresh).getByPlaceholderText('Record contact attempts, agreed actions and resolution…'),
    'Called the rider; driver reassigned; rider home safe.',
  );
  await user.click(within(fresh).getByRole('button', { name: 'Resolve incident' }));
  expect(await screen.findByText(/Resolution: Called the rider/)).toBeInTheDocument();
});

test('a vehicle with a taken registration is refused', async () => {
  const { user } = start('/fleet');
  await user.click(await screen.findByRole('button', { name: 'Add vehicle' }));
  const dialog = await screen.findByRole('dialog', { name: 'Add vehicle' });
  for (const [label, value] of [
    ['Make', 'Toyota'],
    ['Model', 'Corolla'],
    ['Year', '2022'],
    ['Registration', 'LT 211 RB'],
    ['Colour', 'White'],
    ['Daily rate (FCFA)', '30000'],
  ] as const) {
    await user.type(within(dialog).getByLabelText(label), value);
  }
  await user.click(within(dialog).getByRole('button', { name: 'Add vehicle' }));
  expect(await screen.findByText('That registration is already in the fleet.')).toBeInTheDocument();
});

test('every section opens from the sidebar', async () => {
  const { user } = start('/overview');
  const nav = await screen.findByRole('navigation', { name: 'Sections' });
  for (const [link, marker] of [
    ['Live operations', 'Active trips'],
    ['Rides', 'Export rides'],
    ['Rental bookings', 'Create booking'],
    ['Drivers', 'Export drivers'],
    ['Fleet', 'Add vehicle'],
    [/Safety & security/, 'Severity queue'],
    ['Payments', 'Export statement'],
  ] as const) {
    await user.click(within(nav).getByRole('link', { name: link }));
    expect(await screen.findByText(marker)).toBeInTheDocument();
  }
});

test('header search sends each reference to its section', () => {
  expect(searchTarget('sa-091')).toBe('/safety?case=SA-091');
  expect(searchTarget('RN-2048')).toBe('/rentals?q=RN-2048');
  expect(searchTarget('DR-032')).toBe('/drivers?q=DR-032');
  expect(searchTarget('TX-8801')).toBe('/payments?q=TX-8801');
  expect(searchTarget('LT 211 RB')).toBe('/fleet?q=LT%20211%20RB');
  expect(searchTarget('RD-1042')).toBe('/rides?q=RD-1042');
  expect(searchTarget('Akwa')).toBe('/live?q=Akwa');
});

test('searching a place on the live map centres the map there', async () => {
  const { user } = start('/live');
  const box = await screen.findByRole('searchbox', { name: 'Find driver, rider, trip ID or place' });
  await user.type(box, 'Makepe{Enter}');
  expect(await screen.findByText('Map centred on Makepe')).toBeInTheDocument();
  await user.click(screen.getByRole('button', { name: 'Clear' }));
  expect(screen.queryByText('Map centred on Makepe')).not.toBeInTheDocument();
});

test('a header search for a place opens the live map on it', async () => {
  const { user } = start('/overview');
  await user.type(
    await screen.findByRole('searchbox', { name: 'Search trips, bookings, people or places' }),
    'Bonapriso{Enter}',
  );
  expect(await screen.findByText('Map centred on Bonapriso')).toBeInTheDocument();
});
