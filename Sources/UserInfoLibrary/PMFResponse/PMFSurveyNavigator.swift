//
//  PMFSurveyNavigator.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/29/25.
//

import Foundation
import SwiftUI


@MainActor
public class PMFSurveyNavigator {
    private var navigationController: UINavigationController?

    public init() {}

    public func startSurvey(from viewController: UIViewController, initialView: some View) {
        let hostingController = UIHostingController(rootView: initialView)
        navigationController = UINavigationController(rootViewController: hostingController)
        navigationController?.modalPresentationStyle = .fullScreen
        viewController.present(navigationController!, animated: true, completion: nil)
    }

    public func presentMultipleChoiceQuestion(onNext: @escaping (String) -> Void) {
        print("PMF Manager - Presenting multiple choice question")
        let multipleChoiceView = MultipleChoiceQuestionView(onNextTapped: onNext)
        pushSurveyStep(view: multipleChoiceView)
    }

    public func presentFillInTheBlankQuestions(onSubmit: @escaping () -> Void) {
        let fillInTheBlankView = FillInTheBlankQuestionsView(onSubmitTapped: onSubmit)
        pushSurveyStep(view: fillInTheBlankView)
    }

    private func pushSurveyStep(view: some View) {
        print("PMF Manager - Attempting to push survey step")
        let hostingController = UIHostingController(rootView: view)
        guard let navigationController = navigationController else {
            print("PMF Manager - Navigation controller is nil!")
            return
        }
        navigationController.pushViewController(hostingController, animated: true)
    }

    public func dismissSurvey() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
