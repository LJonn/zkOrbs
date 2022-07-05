import Footer from "../components/footer";
import Header from "../components/header";
import Layout from "../components/layout";
import '../styles/globals.css';

function MyApp({ Component, pageProps }) {
  return (
    <Layout>
      <div>
        <Component {...pageProps} />

      </div>
    </Layout>
  );
}

export default MyApp;
