// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Rental Agreement Management Contract
 * @dev A simple contract to manage rental agreements between landlords and tenants.
 */
contract Project {
    struct RentalAgreement {
        address landlord;
        address tenant;
        uint256 monthlyRent;
        uint256 securityDeposit;
        bool isActive;
    }

    uint256 public agreementCount;
    mapping(uint256 => RentalAgreement) public agreements;

    event AgreementCreated(
        uint256 indexed agreementId,
        address indexed landlord,
        address indexed tenant
    );

    event RentPaid(
        uint256 indexed agreementId,
        address indexed tenant,
        uint256 amount
    );

    event AgreementTerminated(uint256 indexed agreementId);

    /**
     * @notice Create a new rental agreement
     * @param _tenant Address of the tenant
     * @param _monthlyRent Monthly rent amount
     * @param _securityDeposit Deposit amount
     */
    function createAgreement(
        address _tenant,
        uint256 _monthlyRent,
        uint256 _securityDeposit
    ) external {
        agreementCount++;
        agreements[agreementCount] = RentalAgreement({
            landlord: msg.sender,
            tenant: _tenant,
            monthlyRent: _monthlyRent,
            securityDeposit: _securityDeposit,
            isActive: true
        });

        emit AgreementCreated(agreementCount, msg.sender, _tenant);
    }

    /**
     * @notice Tenant pays rent
     * @param _agreementId ID of the agreement
     */
    function payRent(uint256 _agreementId) external payable {
        RentalAgreement storage ag = agreements[_agreementId];
        require(ag.isActive, "Agreement is not active");
        require(msg.sender == ag.tenant, "Only tenant can pay rent");
        require(msg.value == ag.monthlyRent, "Incorrect rent amount");

        payable(ag.landlord).transfer(msg.value);

        emit RentPaid(_agreementId, msg.sender, msg.value);
    }

    /**
     * @notice Terminate an active rental agreement
     * @param _agreementId ID of the agreement
     */
    function terminateAgreement(uint256 _agreementId) external {
        RentalAgreement storage ag = agreements[_agreementId];
        require(ag.isActive, "Agreement already inactive");
        require(
            msg.sender == ag.landlord || msg.sender == ag.tenant,
            "Not authorized"
        );

        ag.isActive = false;

        emit AgreementTerminated(_agreementId);
    }
}
