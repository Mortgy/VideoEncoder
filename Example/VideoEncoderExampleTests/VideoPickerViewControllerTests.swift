//
//  VideoPickerViewControllerTests.swift
//  VideoEncoderTests
//
//  Created by Mortgy on 4/16/21.
//

import XCTest
@testable import VideoEncoder

class VideoPickerViewControllerTests: XCTestCase {

    func test_VideoPickerViewController_isInitialRootViewController() {
        // given
        let coordinator = Coordinator()
        
        // when
        coordinator.start()
        let rootController = coordinator.rootViewController
        
        // then
        XCTAssertTrue(rootController is VideoPickerViewController)
    }
    
    func test_VideoPickerController_viewModelPropertiesValidation() {
        
        // given
        let coordinator = Coordinator()
        
        // when
        coordinator.start()
        let rootController = coordinator.rootViewController as? VideoPickerViewController
        
        // then
        XCTAssertNotNil(rootController?.viewModel.picker)
        XCTAssertNotNil(rootController?.viewModel.coordinator)
    }

}
