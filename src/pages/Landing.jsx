import { Link } from 'react-router-dom';

export default function Landing() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-lm-green to-gray-900">
      {/* Header */}
      <header className="absolute w-full z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-20">
            <div className="flex items-center">
              <span className="text-3xl font-bold text-lm-gold">LM</span>
              <span className="ml-2 text-white font-semibold text-lg">Lucrative Merchants</span>
            </div>
            <div className="flex items-center space-x-4">
              <Link
                to="/login"
                className="text-white hover:text-lm-gold transition-colors"
              >
                Sign In
              </Link>
              <Link
                to="/signup"
                className="bg-lm-gold text-white px-6 py-2 rounded-lg hover:bg-yellow-600 transition-colors font-semibold"
              >
                Get Started
              </Link>
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <div className="relative pt-32 pb-20 sm:pt-40 sm:pb-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h1 className="text-4xl sm:text-5xl md:text-6xl font-bold text-white mb-6">
              Find Your Perfect
              <span className="block text-lm-gold">Payment Processor</span>
            </h1>
            <p className="text-xl text-gray-300 mb-8 max-w-3xl mx-auto">
              Get matched with the right payment processing partner for your business. 
              Compare rates, upload documents, and start processing in days—not weeks.
            </p>
            <div className="flex flex-col sm:flex-row justify-center gap-4">
              <Link
                to="/signup"
                className="bg-lm-gold text-white px-8 py-4 rounded-lg hover:bg-yellow-600 transition-colors font-semibold text-lg"
              >
                Start Application
              </Link>
              <a
                href="https://lucrativemerchants.com"
                target="_blank"
                rel="noopener noreferrer"
                className="bg-white text-lm-green px-8 py-4 rounded-lg hover:bg-gray-100 transition-colors font-semibold text-lg"
              >
                Learn More
              </a>
            </div>
          </div>
        </div>
      </div>

      {/* Features Section */}
      <div className="bg-white py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">
              How It Works
            </h2>
            <p className="text-gray-600">
              Three simple steps to get approved and start processing
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {/* Step 1 */}
            <div className="text-center">
              <div className="bg-lm-gold text-white w-16 h-16 rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-4">
                1
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                Create Your Profile
              </h3>
              <p className="text-gray-600">
                Tell us about your business—industry, volume, transaction type. Takes 5 minutes.
              </p>
            </div>

            {/* Step 2 */}
            <div className="text-center">
              <div className="bg-lm-gold text-white w-16 h-16 rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-4">
                2
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                Get Matched
              </h3>
              <p className="text-gray-600">
                Our matching engine finds the best processors for your needs from 15+ partners.
              </p>
            </div>

            {/* Step 3 */}
            <div className="text-center">
              <div className="bg-lm-gold text-white w-16 h-16 rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-4">
                3
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                Upload & Sign
              </h3>
              <p className="text-gray-600">
                Upload documents, review your pre-filled application, and e-sign. Done.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="bg-lm-green py-16">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl font-bold text-white mb-4">
            Ready to Find Your Processor?
          </h2>
          <p className="text-gray-300 mb-8">
            Join hundreds of merchants who trust Lucrative Merchants for payment processing.
          </p>
          <Link
            to="/signup"
            className="inline-block bg-lm-gold text-white px-8 py-4 rounded-lg hover:bg-yellow-600 transition-colors font-semibold text-lg"
          >
            Get Started Now
          </Link>
        </div>
      </div>
    </div>
  );
}
