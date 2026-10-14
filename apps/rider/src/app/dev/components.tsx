import { ComponentGallery } from '@iyodriver/ui/dev';
import { Redirect, router } from 'expo-router';

/** Hidden component gallery for comparing @iyodriver/ui against Figma. Dev builds only. */
export default function ComponentsGalleryScreen() {
  if (!__DEV__) return <Redirect href="/" />;
  return <ComponentGallery flowLabel="RIDER · DEV" onBack={() => router.back()} />;
}
