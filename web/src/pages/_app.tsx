import type { AppProps } from "next/app";
import Layout from "@/components/layout";
import { ToastContainer } from "react-toastify";
import Web3Provider from "@/components/Web3Provider";
import "@/styles/globals.css";
import "react-toastify/dist/ReactToastify.css";

export default function App({ Component, pageProps }: AppProps) {
  return (
    <Web3Provider>
      <Layout>
        <ToastContainer />
        <Component {...pageProps} />
      </Layout>
    </Web3Provider>
  );
}
