interface Props { params: { id: string } }
export default function WebinarWaiting({ params }: Props) {
  return (
    <main className="mx-auto max-w-xl px-6 py-10">
      <h1 className="text-2xl font-semibold mb-4">Webinaire {params.id}</h1>
      <p>Salle d'attente.</p>
    </main>
  )
}

