enum UserRole { admin, manager, viewer }

enum Permission {
  viewProduct,
  createProduct,
  editStock,
  deleteProduct,
  manageUsers,
}

extension UserRolePermission on UserRole {
  bool can(Permission permission) {
    return switch (this) {
      UserRole.admin => true,
      UserRole.manager =>
        permission == Permission.viewProduct ||
            permission == Permission.createProduct ||
            permission == Permission.editStock,
      UserRole.viewer => permission == Permission.viewProduct,
    };
  }
}
