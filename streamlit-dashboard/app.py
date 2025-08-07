import streamlit as st
import plotly.express as px
from datetime import datetime, timedelta

st.set_page_config(page_title="Dashboard PM IA", layout="wide")

col1, col2, col3, col4 = st.columns(4)
completed_count = 3
study_hours = 12
avg_score = 84
rank = 15
with col1:
    st.metric("Formations complétées", completed_count, "+1")
with col2:
    st.metric("Temps d'étude", f"{study_hours}h", "+2h")
with col3:
    st.metric("Score moyen", f"{avg_score}%", "+3%")
with col4:
    st.metric("Rang communauté", rank, "+1")

# Courbe de progression simulée
base = datetime.now() - timedelta(days=14)
progress_data = [{"date": (base + timedelta(days=i)).date(), "score": 60 + i} for i in range(15)]
fig = px.line(progress_data, x='date', y='score', title="Évolution des scores")
st.plotly_chart(fig, use_container_width=True)

st.subheader("🎯 Recommandations personnalisées")
for rec in ["Approfondir l'analyse de cohortes", "Pratique A/B testing sur funnel"]:
    st.info(rec)

