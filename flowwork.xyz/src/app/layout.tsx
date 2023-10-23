import './globals.css'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'

const inter = Inter({ subsets: [ 'latin' ] })

export const metadata: Metadata = {
  title: 'Flow Work - Find Your Flow',
  description: 'Flow Work is an open-source productivity app for Mac designed to help you and your team dive into collaborative, virtual coworking sessions in real time. It’s teamwork, made super easy.',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
