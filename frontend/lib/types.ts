export type OnboardingForm = {
  experience: 'beginner' | 'intermediate' | 'expert'
  interests: string[]
  goals: string[]
  company_size: string
}

export type Formation = {
  id: string
  title: string
  level: string
}

