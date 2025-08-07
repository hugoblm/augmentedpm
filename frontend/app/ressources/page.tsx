export default function ResourcesPage() {
  return (
    <main className="mx-auto max-w-5xl px-6 py-10">
      <h1 className="text-2xl font-semibold mb-6">Ressources</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <a className="border rounded p-4 hover:shadow" href="/ressources/blog/intro">Blog</a>
        <a className="border rounded p-4 hover:shadow" href="/ressources/downloads">Téléchargements</a>
      </div>
    </main>
  )
}

