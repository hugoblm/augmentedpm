interface Props { params: { id: string } }
export default function FormationDetail({ params }: Props) {
  return (
    <main className="mx-auto max-w-3xl px-6 py-10">
      <h1 className="text-2xl font-semibold mb-4">Formation {params.id}</h1>
      <p>Introduction et aperçu des modules.</p>
    </main>
  )
}

