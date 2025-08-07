import streamlit as st
import os
from typing import List, Dict

st.set_page_config(page_title="Assistant PM IA", page_icon="🤖", layout="wide")

# Auth par token (query param)
if "token" not in st.query_params:
    st.error("Non autorisé")
    st.stop()

if "messages" not in st.session_state:
    st.session_state.messages: List[Dict[str, str]] = []

st.title("🤖 Assistant PM IA")
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

if prompt := st.chat_input("Votre question Product Management..."):
    st.session_state.messages.append({"role": "user", "content": prompt})
    # Appel Ragie simulé
    response = f"Réponse basée sur la base de connaissances PM (stub). Question: {prompt}"
    st.session_state.messages.append({"role": "assistant", "content": response})
    st.rerun()

