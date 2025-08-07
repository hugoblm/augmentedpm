export default function FormationsPage() {
  return (
    <main className="mx-auto max-w-5xl px-6 py-10">
      <h1 className="text-2xl font-semibold mb-4">Formations</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {[1,2,3].map(i => (
          <a key={i} className="border rounded p-4 hover:shadow" href={`/formations/${i}`}>Formation {i}</a>
        ))}
      </div>
    </main>
  )
}

