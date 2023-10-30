import './globals.css';
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';

const inter = Inter({ subsets: [ 'latin' ] });

export const metadata: Metadata = {
  title: 'Flow Work - Find Your Flow',
  description:
    'Flow Work is a productivity app for Mac designed for teams and individuals to dive into real-time, collaborative virtual coworking sessions. It’s teamwork, made super easy.',
  icons: [
    "/favicon.ico"
  ]
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang='en'>
      <body className={inter.className}>{children}</body>
    </html>
  );
}
