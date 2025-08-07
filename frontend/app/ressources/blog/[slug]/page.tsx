interface Props { params: { slug: string } }
export default function BlogPost({ params }: Props) {
  return (
    <main className="mx-auto max-w-3xl px-6 py-10">
      <h1 className="text-2xl font-semibold mb-4">Article: {params.slug}</h1>
      <article>
        <p>Contenu d'exemple.</p>
      </article>
    </main>
  )
}

