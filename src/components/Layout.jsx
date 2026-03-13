import { Outlet, Link, useNavigate } from 'react-router-dom';
import { auth } from '../lib/supabase';

export default function Layout({ user }) {
  const navigate = useNavigate();

  const handleSignOut = async () => {
    await auth.signOut();
    navigate('/');
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            {/* Logo */}
            <Link to="/dashboard" className="flex items-center">
              <span className="text-2xl font-bold text-lm-gold">LM</span>
              <span className="ml-2 text-gray-900 font-semibold">Merchant Portal</span>
            </Link>

            {/* Navigation */}
            <nav className="hidden md:flex space-x-8">
              <Link
                to="/dashboard"
                className="text-gray-700 hover:text-lm-gold transition-colors"
              >
                Dashboard
              </Link>
              <Link
                to="/profile"
                className="text-gray-700 hover:text-lm-gold transition-colors"
              >
                Profile
              </Link>
              <Link
                to="/matches"
                className="text-gray-700 hover:text-lm-gold transition-colors"
              >
                Matches
              </Link>
              <Link
                to="/documents"
                className="text-gray-700 hover:text-lm-gold transition-colors"
              >
                Documents
              </Link>
              <Link
                to="/applications"
                className="text-gray-700 hover:text-lm-gold transition-colors"
              >
                Applications
              </Link>
            </nav>

            {/* User menu */}
            <div className="flex items-center space-x-4">
              <span className="text-sm text-gray-600">{user?.email}</span>
              <button
                onClick={handleSignOut}
                className="text-sm text-gray-700 hover:text-lm-gold transition-colors"
              >
                Sign Out
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Outlet />
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-gray-200 mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <p className="text-center text-sm text-gray-500">
            © 2026 Lucrative Merchants. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
