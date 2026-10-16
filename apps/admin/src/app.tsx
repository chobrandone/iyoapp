import { QueryClientProvider, type QueryClient } from '@tanstack/react-query';
import { lazy, Suspense, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { BrowserRouter, Link, MemoryRouter, Navigate, Route, Routes } from 'react-router';

import type { AdminRepository } from './data/repository';
import { DataProvider, useAdmin } from './data/queries';
import { Loading } from './ui/kit';
import { Shell } from './ui/shell';
import { ToastProvider } from './ui/toast';
import { SignInScreen } from './screens/sign-in';

// One chunk per section: the first paint only loads what it shows.
const OverviewScreen = lazy(() => import('./screens/overview'));
const LiveScreen = lazy(() => import('./screens/live'));
const RidesScreen = lazy(() => import('./screens/rides'));
const RideDetailScreen = lazy(() => import('./screens/ride-detail'));
const RentalsScreen = lazy(() => import('./screens/rentals'));
const DriversScreen = lazy(() => import('./screens/drivers'));
const FleetScreen = lazy(() => import('./screens/fleet'));
const SafetyScreen = lazy(() => import('./screens/safety'));
const PaymentsScreen = lazy(() => import('./screens/payments'));

function Gate() {
  const admin = useAdmin();
  if (admin === undefined) return <Loading />;
  if (admin === null) return <SignInScreen />;
  return <Shell admin={admin} />;
}

function NotFound() {
  const { t } = useTranslation();
  return (
    <div className="flex flex-col items-start gap-3 p-8 text-[13px]">
      <p>{t('pageNotFound')}</p>
      <Link
        to="/overview"
        className="inline-flex h-10 items-center rounded-[10px] bg-white px-4 text-[12px] font-semibold"
      >
        {t('backToOverview')}
      </Link>
    </div>
  );
}

const page = (el: ReactNode) => <Suspense fallback={<Loading />}>{el}</Suspense>;

// Declarative routes: the dashboard loads data with TanStack Query, not router loaders.
function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<Gate />}>
        <Route index element={<Navigate to="/overview" replace />} />
        <Route path="overview" element={page(<OverviewScreen />)} />
        <Route path="live" element={page(<LiveScreen />)} />
        <Route path="rides" element={page(<RidesScreen />)} />
        <Route path="rides/:id" element={page(<RideDetailScreen />)} />
        <Route path="rentals" element={page(<RentalsScreen />)} />
        <Route path="drivers" element={page(<DriversScreen />)} />
        <Route path="fleet" element={page(<FleetScreen />)} />
        <Route path="safety" element={page(<SafetyScreen />)} />
        <Route path="payments" element={page(<PaymentsScreen />)} />
        <Route path="*" element={<NotFound />} />
      </Route>
    </Routes>
  );
}

export function App({
  repo,
  client,
  now,
  initialPath,
}: {
  repo: AdminRepository;
  client: QueryClient;
  /** Fixed clock for tests and design reviews. */
  now?: Date;
  /** Tests run on an in-memory router starting here. */
  initialPath?: string;
}) {
  return (
    <QueryClientProvider client={client}>
      <DataProvider repo={repo} now={now}>
        <ToastProvider>
          {initialPath ? (
            <MemoryRouter initialEntries={[initialPath]}>
              <AppRoutes />
            </MemoryRouter>
          ) : (
            <BrowserRouter>
              <AppRoutes />
            </BrowserRouter>
          )}
        </ToastProvider>
      </DataProvider>
    </QueryClientProvider>
  );
}
