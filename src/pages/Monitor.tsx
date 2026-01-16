import React from 'react';
import { ProxyMonitor } from '../components/proxy/ProxyMonitor';

const Monitor: React.FC = () => {
    return (
        <div className="h-full w-full flex flex-col bg-gray-50 dark:bg-base-200">
            {/* Main Content (Full Screen Monitor) */}
            <div className="flex-1 p-4 overflow-hidden">
                <ProxyMonitor className="h-full border border-gray-200 dark:border-base-300 shadow-md" />
            </div>
        </div>
    );
};

export default Monitor;