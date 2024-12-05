//
//  Plugins.swift
//  Tenant
//
//  Created by liuhongli on 2024/4/4.
//

import Foundation
import Moya

#if DEBUG
public let plugins_bear: [PluginType] = [LoggerPlugin, FilterPlugin(), ErrorHandlerPlugin()]
#else
public let plugins_bear: [PluginType] = [FilterPlugin(), ErrorHandlerPlugin()]
#endif


