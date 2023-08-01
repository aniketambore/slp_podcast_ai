<div align="center">
    <img src="https://i.ibb.co/0hBzXtr/slp-logo.png" width="80px" alt="SLP AI Logo"/>
    <h1> Stephan Livera Podcast AI</h1>
</div>

Hey there, welcome to the Stephan Livera Podcast AI project! 🚀

## Introduction

Stephan Livera Podcast AI is a revolutionary platform that aims to create an interactive and informative podcast experience for users interested in Bitcoin and Lightning technology. The project allows users to engage in conversations with an AI representation of Stephan Livera, one of the leading hosts in the Bitcoin community.

## How it Works

The Stephan Livera Podcast AI works like a real podcast, but with a twist! Users can participate as guests in podcast-like conversations with the Stephan Livera AI. These interactions are not only educational but also entertaining, as the AI strives to emulate the hosting style of Stephan Livera himself.

After each podcast conversation, the full transcript is published on Nostr. The conversation includes the lightning address of the user who participated as a guest.

## Features

- **Informative Conversations:** Engage in thought-provoking discussions with the AI, covering various topics related to Bitcoin and Lightning technology.

- **Lightning-Based Tips:** Users can tip their favorite podcast conversations directly using lightning payments. The lightning address of each guest is attached to the podcast for easy tipping.

- **Podcast Feed:** Check out a feed of all published podcast conversations and discover exciting discussions from other users.

## Project Interface

The project interface is designed to be user-friendly and intuitive. Users can access the Stephan Livera Podcast AI platform by visiting [https://slp-ai.netlify.app/#/](https://slp-ai.netlify.app/#/). For smooth functionality, the browser must support the WebLN provider to facilitate communication with the Metador API, which connects to the OpenAI API and to access that it uses L402 spec, so the user needs to pay for that.

## Getting Started

To run the Stephan Livera Podcast AI project locally, follow these steps:

1. Clone the repository:

```bash
git clone https://github.com/aniketambore/slp_podcast_ai.git
```

2. Install dependencies:

```bash
cd slp_podcast_ai

flutter pub get
```

3. Create a `.env` file at the root of the project with the following content:

```bash
NOSTR_PRIV_KEY=<Your nostr priv key hex>
NOSTR_PUB_KEY=<Your nostr pub key hex>
ENDING_SECRET=<Random Secret>
```

Then run the generator:

```bash
flutter pub run build_runner build
```

Then run the project for web.

> Note: To enable seamless payments and full functionality, users must have a WebLN provider and sufficient funds in their Lightning Network wallet.

## Future Enhancements
I've some big plans for the future of the Stephan Livera Podcast AI project! Some of the planned enhancements include:

- **In-App Wallet**: Integrate an in-app wallet for automatic payment of AI conversations using Breez SDK.
- **Voice Clone**: Create a unique voice clone of Stephan Livera for an immersive experience.
- **Speech-to-Text and Text-to-Speech**: Enable audio interactions between users and the AI.

Welcoming contributions from the community to help bring these enhancements to life!

## Technology Stack
- **Frontend**: Flutter framework.
- **API Communication**: Matador API for interaction with the OpenAI API.
- **Lightning Integration**: LNURLPay for generating lightning invoices for podcast tipping.
- **WebLN**: Facilitating communication with WebLN providers.

## Connect
I'd love to hear from you! Connect with me on Twitter ([@Anipy1](https://twitter.com/Anipy1)) or find me on Nostr ([@Anipy](https://snort.social/p/npub1clqc0wnk2vk42u35jzhc3emd64c0u4g6y3su4x44g26s8waj2pzskyrp9x)).

## Contributing
Contributions are more than welcome! Whether it's bug fixes, new features, or general improvements, I appreciate your help in making this project even better.

Thank you for checking out the Stephan Livera Podcast AI project. I hope you enjoy the unique experience it offers. Feel free to reach out to me if you have any questions or feedback. Happy podcasting! 🎙️