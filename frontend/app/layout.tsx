import './globals.css'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Formly - Product Management IA',
  description: 'Plateforme e-learning IA pour Product Managers',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="fr">
      <body className="min-h-screen bg-white text-gray-900">{children}</body>
    </html>
  )
}

